import XCTest
@testable import CryptoWallet

final class MnemonicTests: XCTestCase {
    func testGeneratedMnemonicHas12Words() throws {
        let mnemonic = try MnemonicService.generate(strength: .words12)
        defer { mnemonic.wipe() }
        XCTAssertEqual(MnemonicService.words(in: mnemonic.string).count, 12)
    }

    func testGeneratedMnemonicHas24Words() throws {
        let mnemonic = try MnemonicService.generate(strength: .words24)
        defer { mnemonic.wipe() }
        XCTAssertEqual(MnemonicService.words(in: mnemonic.string).count, 24)
    }

    func testGeneratedMnemonicPassesBIP39Checksum() throws {
        let mnemonic = try MnemonicService.generate(strength: .words12)
        defer { mnemonic.wipe() }
        XCTAssertTrue(MnemonicService.isValid(mnemonic.string))
    }

    func testTwoGeneratedMnemonicsAreDifferent() throws {
        let first = try MnemonicService.generate(strength: .words12)
        let second = try MnemonicService.generate(strength: .words12)
        defer { first.wipe(); second.wipe() }
        XCTAssertNotEqual(first.string, second.string)
    }

    func testInvalidPhraseIsRejected() {
        XCTAssertFalse(MnemonicService.isValid("not a real recovery phrase at all here"))
    }

    func testEmptyPhraseIsRejected() {
        XCTAssertFalse(MnemonicService.isValid(""))
    }

    func testNormalizeLowercasesAndTrims() {
        let normalized = MnemonicService.normalize("  Abandon  ABANDON abandon  ")
        XCTAssertEqual(normalized, "abandon abandon abandon")
    }

    func testKnownValidTestVectorPasses() {
        // The canonical all-"abandon" BIP-39 test vector (widely published,
        // used only to sanity-check checksum validation logic — never used
        // to derive a real wallet).
        let phrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        XCTAssertTrue(MnemonicService.isValid(phrase))
    }
}
