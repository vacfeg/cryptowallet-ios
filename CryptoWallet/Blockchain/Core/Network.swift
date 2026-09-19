import Foundation

/// A blockchain network the wallet knows about. EVM networks are identified
/// by `chainID`; non-EVM networks (Bitcoin, Solana, Tron) leave it `nil` and
/// are identified by `id` alone.
struct Network: Identifiable, Codable, Hashable {
    let id: String
    let kind: NetworkKind
    let name: String
    let symbol: String
    let chainID: Int?
    let rpcURL: URL?
    let explorerBaseURL: URL?
    let iconSystemName: String
    let coinGeckoPlatformID: String?
    let coinGeckoNativeID: String
    let decimals: Int
    let isTestnet: Bool

    func explorerTransactionURL(hash: String) -> URL? {
        guard let base = explorerBaseURL else { return nil }
        return base.appendingPathComponent("tx").appendingPathComponent(hash)
    }

    func explorerAddressURL(address: String) -> URL? {
        guard let base = explorerBaseURL else { return nil }
        return base.appendingPathComponent("address").appendingPathComponent(address)
    }
}
