import Foundation

/// Hand-rolled ABI encoding for the two ERC-20 calls this app needs.
/// Intentionally not a dependency: `balanceOf`/`transfer` calldata is a
/// fixed, trivial layout (4-byte selector + 32-byte-padded arguments), and
/// encoding it directly avoids pulling in a general-purpose ABI library for
/// two function signatures.
enum ERC20 {
    static func balanceOfCalldata(owner: String) -> String? {
        guard let addressArg = padAddress(owner) else { return nil }
        return "0x70a08231" + addressArg
    }

    static func transferCalldata(to: String, amount: Decimal, decimals: Int) -> Data? {
        guard let addressArg = padAddress(to) else { return nil }
        let rawHex = BigNumber.rawHex(fromTokenAmount: amount, decimals: decimals)
        let amountArg = padHex(rawHex)
        let calldataHex = "a9059cbb" + addressArg + amountArg
        return Data(hex: calldataHex)
    }

    private static func padAddress(_ address: String) -> String? {
        var hex = address
        if hex.hasPrefix("0x") { hex.removeFirst(2) }
        guard hex.count == 40 else { return nil }
        return String(repeating: "0", count: 24) + hex.lowercased()
    }

    private static func padHex(_ hex: String) -> String {
        var value = hex
        if value.hasPrefix("0x") { value.removeFirst(2) }
        if value.isEmpty { value = "0" }
        let padding = max(0, 64 - value.count)
        return String(repeating: "0", count: padding) + value
    }
}
