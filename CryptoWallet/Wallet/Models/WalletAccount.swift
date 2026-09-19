import Foundation

/// A derived account within the wallet. EVM chains share one address per
/// derivation index (see `CoinTypeMapping`), so a single `.evm` account
/// covers Ethereum, Base, Arbitrum, Optimism, Polygon, BNB Chain, and
/// Avalanche at once; Bitcoin/Solana/Tron each get their own.
///
/// Only public data lives here — address and label. The private key never
/// leaves `KeychainManager`/`WalletManager`.
struct WalletAccount: Identifiable, Codable, Hashable {
    let id: String
    let kind: NetworkKind
    let derivationIndex: Int
    let address: String
    var label: String

    static func makeID(kind: NetworkKind, derivationIndex: Int) -> String {
        "\(kind.rawValue).\(derivationIndex)"
    }
}

/// Public, non-secret metadata for one wallet (a mnemonic's derived
/// accounts). Persisted in `LocalStore`; the mnemonic itself lives only in
/// the Keychain, addressed by `id`.
struct WalletMetadata: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var accounts: [WalletAccount]
    let createdAt: Date
    var backupConfirmed: Bool

    func account(kind: NetworkKind) -> WalletAccount? {
        accounts.first { $0.kind == kind && $0.derivationIndex == 0 }
    }
}
