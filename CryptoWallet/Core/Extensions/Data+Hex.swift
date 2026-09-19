import Foundation

extension Data {
    /// Hex string with no "0x" prefix, e.g. "a3f1".
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }

    /// "0x"-prefixed hex, the format EVM RPCs expect for addresses/tx data.
    var hexPrefixed: String {
        "0x" + hexString
    }

    init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("0x") { hex.removeFirst(2) }
        guard hex.count % 2 == 0 else { return nil }

        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}
