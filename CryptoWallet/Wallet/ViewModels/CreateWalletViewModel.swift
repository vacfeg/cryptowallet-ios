import Foundation
import Combine

// Not `@MainActor` — see the note on `AppState` for why.
final class CreateWalletViewModel: ObservableObject {
    @Published private(set) var mnemonic: SecureBytes?
    @Published private(set) var walletID: String?
    @Published var errorMessage: String?

    /// The words as a display array — read from `mnemonic` once, not stored
    /// as a second independent copy of the secret.
    var words: [String] {
        guard let mnemonic else { return [] }
        return MnemonicService.words(in: mnemonic.string)
    }

    func generate(walletManager: WalletManager) {
        do {
            let result = try walletManager.createWallet(strength: .words12)
            walletID = result.walletID
            mnemonic = result.mnemonic
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "We couldn't generate a wallet. Please try again."
        }
    }

    /// Called once the user finishes (or backs out of) the recovery-phrase
    /// screens — the plaintext mnemonic has no reason to stay in memory
    /// past this point.
    func wipeMnemonic() {
        mnemonic?.wipe()
        mnemonic = nil
    }

    func confirmBackup(walletManager: WalletManager) {
        guard let walletID else { return }
        walletManager.confirmBackup(walletID: walletID)
    }
}
