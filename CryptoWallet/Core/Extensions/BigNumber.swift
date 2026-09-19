import Foundation

/// EVM balances arrive as arbitrary-precision integers (uint256, hex-encoded
/// over JSON-RPC). Swift has no built-in big integer type; rather than take
/// on a whole BigInt dependency just for display math, we decode directly
/// into `Decimal`, which safely covers every realistic token balance
/// (`supply * 10^decimals` for real-world tokens stays far under Decimal's
/// ~38 significant digits — this is a display-layer simplification, not
/// used for anything security-critical like signing).
enum BigNumber {
    /// Parses a "0x..." hex-encoded unsigned integer into a `Decimal`.
    static func decimal(fromHex hex: String) -> Decimal {
        var hex = hex
        if hex.hasPrefix("0x") { hex.removeFirst(2) }
        if hex.isEmpty { return 0 }

        var result = Decimal(0)
        for character in hex {
            guard let digit = character.hexDigitValue else { continue }
            result = result * 16 + Decimal(digit)
        }
        return result
    }

    /// Converts a raw on-chain integer amount (e.g. wei) into a human token
    /// amount by dividing by 10^decimals.
    static func tokenAmount(rawHex: String, decimals: Int) -> Decimal {
        let raw = decimal(fromHex: rawHex)
        let divisor = pow(Decimal(10), decimals)
        guard divisor != 0 else { return 0 }
        return raw / divisor
    }

    /// Converts a human token amount back into a "0x..." hex-encoded raw
    /// integer for use in transaction params.
    static func rawHex(fromTokenAmount amount: Decimal, decimals: Int) -> String {
        let scaled = amount * pow(Decimal(10), decimals)
        var rounded = Decimal()
        var input = scaled
        NSDecimalRound(&rounded, &input, 0, .down)

        guard rounded > 0 else { return "0x0" }

        // Decimal -> [UInt8] base-256 via repeated division by 256.
        var digits: [UInt8] = []
        var remainder = Decimal()
        var quotient = rounded
        let twoFiveSix = Decimal(256)
        while quotient > 0 {
            var next = Decimal()
            NSDecimalDivide(&next, &quotient, &twoFiveSix, .down)
            remainder = quotient - (next * twoFiveSix)
            digits.append(UInt8(truncating: remainder as NSDecimalNumber))
            quotient = next
        }
        let bytes = digits.reversed()
        let hex = bytes.map { String(format: "%02x", $0) }.joined()
        let trimmed = hex.drop(while: { $0 == "0" })
        return "0x" + (trimmed.isEmpty ? "0" : String(trimmed))
    }
}
