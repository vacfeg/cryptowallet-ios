import XCTest
@testable import CryptoWallet

final class AmountFormattingTests: XCTestCase {
    func testNilFiatNeverRendersAsNilOrNaN() {
        let result = AmountFormatter.fiat(nil, currency: .usd)
        XCTAssertEqual(result, "--")
        XCTAssertFalse(result.lowercased().contains("nil"))
        XCTAssertFalse(result.lowercased().contains("nan"))
    }

    func testFiatFormattingRoundsToTwoDecimals() {
        let result = AmountFormatter.fiat(Decimal(string: "1234.5")!, currency: .usd)
        XCTAssertTrue(result.contains("1,234.50") || result.contains("1234.50"))
    }

    func testTokenAmountFormattingIncludesSymbol() {
        let result = AmountFormatter.token(Decimal(string: "0.842")!, symbol: "ETH")
        XCTAssertTrue(result.contains("ETH"))
        XCTAssertTrue(result.contains("0.842"))
    }

    func testHexToDecimalRoundTrip() {
        let decoded = BigNumber.decimal(fromHex: "0xde0b6b3a7640000") // 1e18
        XCTAssertEqual(decoded, Decimal(string: "1000000000000000000"))
    }

    func testTokenAmountConvertsWeiToEther() {
        let amount = BigNumber.tokenAmount(rawHex: "0xde0b6b3a7640000", decimals: 18)
        XCTAssertEqual(amount, Decimal(1))
    }

    func testRawHexRoundTripsThroughTokenAmount() {
        let original = Decimal(string: "2.5")!
        let hex = BigNumber.rawHex(fromTokenAmount: original, decimals: 18)
        let roundTripped = BigNumber.tokenAmount(rawHex: hex, decimals: 18)
        XCTAssertEqual(roundTripped, original)
    }

    func testZeroHexParsesToZero() {
        XCTAssertEqual(BigNumber.decimal(fromHex: "0x0"), 0)
        XCTAssertEqual(BigNumber.decimal(fromHex: "0x"), 0)
    }
}
