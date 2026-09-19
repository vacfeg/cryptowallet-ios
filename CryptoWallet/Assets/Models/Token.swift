import Foundation

/// One holdable asset: either a network's native coin (`contractAddress ==
/// nil`) or an ERC-20-style token. Identity is `(network, contractAddress ??
/// "native")`, never the symbol alone — two different tokens can share a
/// ticker, and this app must never conflate them (rule 9).
struct Token: Identifiable, Codable, Hashable {
    let networkID: String
    let contractAddress: String?
    let symbol: String
    let name: String
    let decimals: Int
    let iconSystemName: String
    let coinGeckoID: String?

    var id: String { "\(networkID).\(contractAddress ?? "native")" }
    var isNative: Bool { contractAddress == nil }
}
