import Foundation

/// Parses a scanned QR payload into an address, supporting both a bare
/// address and an EIP-681-style URI (`ethereum:0xAddress`,
/// `bitcoin:bc1...`), which is what most wallets encode into their receive
/// QR codes.
enum CryptoURIParser {
    static func extractAddress(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let colonIndex = trimmed.firstIndex(of: ":") {
            let afterScheme = trimmed[trimmed.index(after: colonIndex)...]
            let addressPart = afterScheme.split(separator: "?").first.map(String.init) ?? String(afterScheme)
            return addressPart.isEmpty ? nil : addressPart
        }

        return trimmed.isEmpty ? nil : trimmed
    }
}
