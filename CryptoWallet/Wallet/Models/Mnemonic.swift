import Foundation
import WalletCore

/// App-level wrapper around WalletCore's BIP-39 implementation. This is
/// intentionally the ONLY file that talks to `WalletCore.Mnemonic`
/// directly — nowhere in the app do we generate or validate a mnemonic by
/// hand (rule: never invent a seed phrase; entropy must come from a proven,
/// audited implementation, not `random()`/`UUID()`).
enum MnemonicStrength: Int, CaseIterable {
    /// 128 bits of entropy -> 12 words. The default: WalletCore's own
    /// recommendation and what every major wallet defaults to.
    case words12 = 128
    /// 256 bits of entropy -> 24 words, for users who want the maximum.
    case words24 = 256

    var wordCount: Int {
        switch self {
        case .words12: return 12
        case .words24: return 24
        }
    }
}

enum MnemonicError: LocalizedError {
    case generationFailed
    case invalidPhrase

    var errorDescription: String? {
        switch self {
        case .generationFailed:
            return "We couldn't generate a wallet. Please try again."
        case .invalidPhrase:
            return "That recovery phrase isn't valid. Check the spelling and word order."
        }
    }
}

enum MnemonicService {
    /// Generates a brand-new mnemonic using WalletCore's CSPRNG-backed BIP-39
    /// implementation (never `arc4random`/`UUID` called directly by app code).
    static func generate(strength: MnemonicStrength = .words12) throws -> SecureBytes {
        guard let wallet = HDWallet(strength: Int32(strength.rawValue), passphrase: "") else {
            throw MnemonicError.generationFailed
        }
        return SecureBytes(string: wallet.mnemonic)
    }

    static func isValid(_ phrase: String) -> Bool {
        Mnemonic.isValid(mnemonic: normalize(phrase))
    }

    static func isValidWord(_ word: String) -> Bool {
        Mnemonic.isValidWord(word: word.lowercased())
    }

    /// Splits on ANY whitespace (spaces, tabs, newlines) — not just a
    /// literal " " — since the import screen's multi-line text editor lets
    /// people paste or type a phrase with a line break between words (a
    /// common way phrases get exported elsewhere), which a space-only split
    /// would silently glue into one invalid "word".
    static func normalize(_ phrase: String) -> String {
        phrase
            .lowercased()
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .joined(separator: " ")
    }

    static func words(in phrase: String) -> [String] {
        normalize(phrase).split(separator: " ").map(String.init)
    }
}
