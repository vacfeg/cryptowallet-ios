import Foundation

/// Single place that maps a `Network` to its `BlockchainProvider`
/// implementation. Adding a new chain later means adding one case here.
enum BlockchainProviderFactory {
    static func provider(for network: Network) -> BlockchainProvider {
        switch network.kind {
        case .evm: return EVMProvider(network: network)
        case .bitcoin: return BitcoinProvider(network: network)
        case .solana: return SolanaProvider(network: network)
        case .tron: return TronProvider(network: network)
        }
    }
}
