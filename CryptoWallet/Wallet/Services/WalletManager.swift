import Foundation
import Combine
import WalletCore

/// The single source of truth for wallet lifecycle: creating, importing,
/// locking/unlocking, deriving accounts, and — the one place private key
/// material is ever reconstructed — signing.
///
/// Non-secret data (wallet names, addresses, the active wallet ID) lives in
/// `LocalStore`. The mnemonic itself lives only in the Keychain, protected
/// by Face ID/Touch ID via `SecAccessControl` (see `KeychainManager`), and
/// is never cached in memory longer than a single operation needs it.
///
/// Not `@MainActor` — see the note on `AppState` for why; every call site
/// in this app already runs on the main thread (SwiftUI actions / `Task`
/// blocks from views), so this stays a conventional `ObservableObject`.
final class WalletManager: ObservableObject {
    @Published private(set) var wallets: [WalletMetadata] = []
    @Published private(set) var activeWalletID: String?
    @Published private(set) var isUnlocked = false

    private let localStore: LocalStore

    init(localStore: LocalStore = LocalStore()) {
        self.localStore = localStore
        self.wallets = localStore.load([WalletMetadata].self, key: StorageKey.walletAccounts) ?? []
        self.activeWalletID = wallets.first?.id
    }

    var hasAnyWallet: Bool { !wallets.isEmpty }

    var activeWallet: WalletMetadata? {
        wallets.first { $0.id == activeWalletID }
    }

    func account(kind: NetworkKind) -> WalletAccount? {
        activeWallet?.account(kind: kind)
    }

    // MARK: - Create

    /// Generates a brand-new wallet. Returns the mnemonic so the caller
    /// (the recovery-phrase screen) can display it for backup — the caller
    /// owns wiping it via `SecureBytes.wipe()` once verification completes.
    func createWallet(strength: MnemonicStrength = .words12, name: String = "My Wallet") throws -> (walletID: String, mnemonic: SecureBytes) {
        let mnemonic = try MnemonicService.generate(strength: strength)
        let walletID = UUID().uuidString
        try persistNewWallet(id: walletID, name: name, mnemonic: mnemonic.string, backupConfirmed: false)
        return (walletID, mnemonic)
    }

    /// Imports an existing wallet from a user-supplied recovery phrase.
    /// Validated via BIP-39 checksum before anything is derived or stored.
    func importWallet(mnemonic rawPhrase: String, name: String = "Imported Wallet") throws -> String {
        let normalized = MnemonicService.normalize(rawPhrase)
        guard MnemonicService.isValid(normalized) else { throw MnemonicError.invalidPhrase }

        let walletID = UUID().uuidString
        // Already backed up by definition — the user just typed it in.
        try persistNewWallet(id: walletID, name: name, mnemonic: normalized, backupConfirmed: true)
        return walletID
    }

    private func persistNewWallet(id: String, name: String, mnemonic: String, backupConfirmed: Bool) throws {
        guard let hdWallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            throw MnemonicError.invalidPhrase
        }

        let accounts = NetworkKind.allCases.map { kind -> WalletAccount in
            let coinType = CoinTypeMapping.coinType(for: kind)
            let address = hdWallet.getAddressForCoin(coin: coinType)
            return WalletAccount(id: WalletAccount.makeID(kind: kind, derivationIndex: 0), kind: kind, derivationIndex: 0, address: address, label: kind.rawValue.capitalized)
        }

        guard let mnemonicData = mnemonic.data(using: .utf8) else { throw MnemonicError.generationFailed }
        try KeychainManager.save(mnemonicData, key: KeychainKey.encryptedSeed(walletID: id), requireBiometry: true)

        let metadata = WalletMetadata(id: id, name: name, accounts: accounts, createdAt: Date(), backupConfirmed: backupConfirmed)
        wallets.append(metadata)
        activeWalletID = id
        isUnlocked = true
        persistWalletList()
    }

    func confirmBackup(walletID: String) {
        guard let index = wallets.firstIndex(where: { $0.id == walletID }) else { return }
        wallets[index].backupConfirmed = true
        persistWalletList()
    }

    // MARK: - Additional accounts (multi-account architecture)

    /// Derives the next account index for a given chain family within the
    /// active wallet — the "manage multiple accounts" requirement. Requires
    /// biometric re-authentication since it must touch the mnemonic.
    func addAccount(kind: NetworkKind, label: String) async throws {
        guard let walletID = activeWalletID else { throw ProviderError.notYetImplemented }
        let mnemonic = try await loadMnemonic(walletID: walletID, reason: "Add a new \(kind.rawValue.capitalized) account")
        defer { mnemonic.wipe() }

        guard let hdWallet = HDWallet(mnemonic: mnemonic.string, passphrase: "") else {
            throw MnemonicError.invalidPhrase
        }

        guard let index = wallets.firstIndex(where: { $0.id == walletID }) else { return }
        let nextIndex = (wallets[index].accounts.filter { $0.kind == kind }.map(\.derivationIndex).max() ?? -1) + 1
        let coinType = CoinTypeMapping.coinType(for: kind)
        let path = derivationPath(coinType: coinType, index: nextIndex)
        let privateKey = hdWallet.getKey(coin: coinType, derivationPath: path)
        let address = coinType.deriveAddress(privateKey: privateKey)

        let account = WalletAccount(id: WalletAccount.makeID(kind: kind, derivationIndex: nextIndex), kind: kind, derivationIndex: nextIndex, address: address, label: label)
        wallets[index].accounts.append(account)
        persistWalletList()
    }

    /// Builds the BIP-44 path for a given account index by taking
    /// WalletCore's own default path for the coin (which is correct for
    /// index 0) and swapping just the final `address_index` component —
    /// avoids hand-encoding each chain's SLIP-44 coin number ourselves.
    private func derivationPath(coinType: CoinType, index: Int) -> String {
        // Confirmed from a real compiler error: `derivationPath` is a
        // method on WalletCore's `CoinType`, not a property.
        let base = coinType.derivationPath()
        var components = base.split(separator: "/").map(String.init)
        guard !components.isEmpty else { return base }
        components[components.count - 1] = "\(index)"
        return components.joined(separator: "/")
    }

    // MARK: - Lock / unlock

    func lock() {
        isUnlocked = false
    }

    func unlockWithBiometrics(reason: String = "Unlock your wallet") async -> Result<Void, BiometricAuthError> {
        let result = await BiometricAuthManager.authenticate(reason: reason)
        if case .success = result {
            isUnlocked = true
        }
        return result
    }

    // MARK: - Signing key access

    /// Loads the mnemonic for `walletID`, triggering the biometric prompt
    /// tied to the Keychain item. Callers MUST call `.wipe()` on the result
    /// as soon as they're done deriving what they need from it.
    func loadMnemonic(walletID: String, reason: String) async throws -> SecureBytes {
        let data = try KeychainManager.load(key: KeychainKey.encryptedSeed(walletID: walletID), prompt: reason)
        return SecureBytes(Array(data))
    }

    /// Derives the raw private key for one account, for signing a single
    /// transaction. The returned `SecureBytes` must be wiped by the caller
    /// immediately after use.
    func privateKey(for account: WalletAccount, walletID: String) async throws -> SecureBytes {
        let mnemonic = try await loadMnemonic(walletID: walletID, reason: "Confirm to sign this transaction")
        defer { mnemonic.wipe() }

        guard let hdWallet = HDWallet(mnemonic: mnemonic.string, passphrase: "") else {
            throw MnemonicError.invalidPhrase
        }
        let coinType = CoinTypeMapping.coinType(for: account.kind)
        let path = derivationPath(coinType: coinType, index: account.derivationIndex)
        let key = hdWallet.getKey(coin: coinType, derivationPath: path)
        return SecureBytes(Array(key.data))
    }

    // MARK: - Reset

    func resetWallet(walletID: String) {
        try? KeychainManager.delete(key: KeychainKey.encryptedSeed(walletID: walletID))
        wallets.removeAll { $0.id == walletID }
        if activeWalletID == walletID {
            activeWalletID = wallets.first?.id
        }
        if wallets.isEmpty {
            isUnlocked = false
        }
        persistWalletList()
    }

    func resetAll() {
        for wallet in wallets {
            try? KeychainManager.delete(key: KeychainKey.encryptedSeed(walletID: wallet.id))
        }
        wallets.removeAll()
        activeWalletID = nil
        isUnlocked = false
        persistWalletList()
    }

    private func persistWalletList() {
        localStore.save(wallets, key: StorageKey.walletAccounts)
    }
}
