import Foundation

/// Static catalog of every network the app ships with. RPC URLs are public,
/// free-tier endpoints so the app works out of the box; power users can
/// override them per-network in Settings > Networks (backed by
/// `Secrets.xcconfig`, never hardcoded private keys).
enum SupportedNetworks {

    static let ethereum = Network(
        id: "ethereum", kind: .evm, name: "Ethereum", symbol: "ETH", chainID: 1,
        rpcURL: URL(string: "https://ethereum-rpc.publicnode.com"),
        explorerBaseURL: URL(string: "https://etherscan.io"),
        iconSystemName: "e.circle.fill",
        coinGeckoPlatformID: "ethereum", coinGeckoNativeID: "ethereum",
        decimals: 18, isTestnet: false
    )

    static let base = Network(
        id: "base", kind: .evm, name: "Base", symbol: "ETH", chainID: 8453,
        rpcURL: URL(string: "https://mainnet.base.org"),
        explorerBaseURL: URL(string: "https://basescan.org"),
        iconSystemName: "b.circle.fill",
        coinGeckoPlatformID: "base", coinGeckoNativeID: "ethereum",
        decimals: 18, isTestnet: false
    )

    static let arbitrum = Network(
        id: "arbitrum", kind: .evm, name: "Arbitrum One", symbol: "ETH", chainID: 42161,
        rpcURL: URL(string: "https://arb1.arbitrum.io/rpc"),
        explorerBaseURL: URL(string: "https://arbiscan.io"),
        iconSystemName: "a.circle.fill",
        coinGeckoPlatformID: "arbitrum-one", coinGeckoNativeID: "ethereum",
        decimals: 18, isTestnet: false
    )

    static let optimism = Network(
        id: "optimism", kind: .evm, name: "Optimism", symbol: "ETH", chainID: 10,
        rpcURL: URL(string: "https://mainnet.optimism.io"),
        explorerBaseURL: URL(string: "https://optimistic.etherscan.io"),
        iconSystemName: "o.circle.fill",
        coinGeckoPlatformID: "optimistic-ethereum", coinGeckoNativeID: "ethereum",
        decimals: 18, isTestnet: false
    )

    static let polygon = Network(
        id: "polygon", kind: .evm, name: "Polygon", symbol: "POL", chainID: 137,
        rpcURL: URL(string: "https://polygon-rpc.com"),
        explorerBaseURL: URL(string: "https://polygonscan.com"),
        iconSystemName: "p.circle.fill",
        coinGeckoPlatformID: "polygon-pos", coinGeckoNativeID: "matic-network",
        decimals: 18, isTestnet: false
    )

    static let bnbChain = Network(
        id: "bnb", kind: .evm, name: "BNB Smart Chain", symbol: "BNB", chainID: 56,
        rpcURL: URL(string: "https://bsc-dataseed.binance.org"),
        explorerBaseURL: URL(string: "https://bscscan.com"),
        iconSystemName: "b.circle.fill",
        coinGeckoPlatformID: "binance-smart-chain", coinGeckoNativeID: "binancecoin",
        decimals: 18, isTestnet: false
    )

    static let avalanche = Network(
        id: "avalanche", kind: .evm, name: "Avalanche C-Chain", symbol: "AVAX", chainID: 43114,
        rpcURL: URL(string: "https://api.avax.network/ext/bc/C/rpc"),
        explorerBaseURL: URL(string: "https://snowtrace.io"),
        iconSystemName: "a.circle.fill",
        coinGeckoPlatformID: "avalanche", coinGeckoNativeID: "avalanche-2",
        decimals: 18, isTestnet: false
    )

    /// Address-derivation-only today — see `NetworkKind.isFullySupported`.
    static let bitcoin = Network(
        id: "bitcoin", kind: .bitcoin, name: "Bitcoin", symbol: "BTC", chainID: nil,
        rpcURL: nil, explorerBaseURL: URL(string: "https://mempool.space"),
        iconSystemName: "bitcoinsign.circle.fill",
        coinGeckoPlatformID: nil, coinGeckoNativeID: "bitcoin",
        decimals: 8, isTestnet: false
    )

    static let solana = Network(
        id: "solana", kind: .solana, name: "Solana", symbol: "SOL", chainID: nil,
        rpcURL: URL(string: "https://api.mainnet-beta.solana.com"),
        explorerBaseURL: URL(string: "https://explorer.solana.com"),
        iconSystemName: "s.circle.fill",
        coinGeckoPlatformID: "solana", coinGeckoNativeID: "solana",
        decimals: 9, isTestnet: false
    )

    static let tron = Network(
        id: "tron", kind: .tron, name: "Tron", symbol: "TRX", chainID: nil,
        rpcURL: nil, explorerBaseURL: URL(string: "https://tronscan.org"),
        iconSystemName: "t.circle.fill",
        coinGeckoPlatformID: "tron", coinGeckoNativeID: "tron",
        decimals: 6, isTestnet: false
    )

    static let evmNetworks: [Network] = [ethereum, base, arbitrum, optimism, polygon, bnbChain, avalanche]
    static let previewOnlyNetworks: [Network] = [bitcoin, solana, tron]
    static let all: [Network] = evmNetworks + previewOnlyNetworks

    static func network(for id: String) -> Network? {
        all.first { $0.id == id }
    }
}
