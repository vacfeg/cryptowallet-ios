import Foundation

/// Curated default token list — native assets plus the major stablecoins on
/// each EVM network. Contract addresses below are the well-known mainnet
/// deployments; double-check them against the network's official block
/// explorer before relying on them for real transfers, since this list was
/// authored without a live chain connection to verify against.
///
/// Users can add any other ERC-20 by contract address from Settings > Assets
/// (`AssetBalanceService.addCustomToken`) — this list is only the default
/// set new accounts start with, not a hardcoded ceiling.
enum TokenList {

    static func nativeToken(for network: Network) -> Token {
        Token(
            networkID: network.id,
            contractAddress: nil,
            symbol: network.symbol,
            name: network.name,
            decimals: network.decimals,
            iconSystemName: network.iconSystemName,
            coinGeckoID: network.coinGeckoNativeID
        )
    }

    static func defaultTokens(for network: Network) -> [Token] {
        [nativeToken(for: network)] + stablecoins(for: network)
    }

    private static func stablecoins(for network: Network) -> [Token] {
        switch network.id {
        case "ethereum":
            return [
                usdt(network, "0xdAC17F958D2ee523a2206206994597C13D831ec7"),
                usdc(network, "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
                dai(network, "0x6B175474E89094C44Da98b954EedeAC495271d0F")
            ]
        case "polygon":
            return [
                usdt(network, "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"),
                usdc(network, "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359"),
                dai(network, "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063")
            ]
        case "arbitrum":
            return [
                usdt(network, "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9"),
                usdc(network, "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"),
                dai(network, "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1")
            ]
        case "optimism":
            return [
                usdt(network, "0x94b008aA00579c1307B0EF2c499aD98a8ce58e58"),
                usdc(network, "0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85"),
                dai(network, "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1")
            ]
        case "base":
            return [
                usdc(network, "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913")
            ]
        case "bnb":
            return [
                usdt(network, "0x55d398326f99059fF775485246999027B3197955"),
                usdc(network, "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d"),
                dai(network, "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3")
            ]
        case "avalanche":
            return [
                usdt(network, "0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7"),
                usdc(network, "0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E")
            ]
        default:
            return []
        }
    }

    private static func usdt(_ network: Network, _ address: String) -> Token {
        Token(networkID: network.id, contractAddress: address, symbol: "USDT", name: "Tether USD", decimals: 6, iconSystemName: "dollarsign.circle.fill", coinGeckoID: "tether")
    }

    private static func usdc(_ network: Network, _ address: String) -> Token {
        Token(networkID: network.id, contractAddress: address, symbol: "USDC", name: "USD Coin", decimals: 6, iconSystemName: "dollarsign.circle.fill", coinGeckoID: "usd-coin")
    }

    private static func dai(_ network: Network, _ address: String) -> Token {
        Token(networkID: network.id, contractAddress: address, symbol: "DAI", name: "Dai Stablecoin", decimals: 18, iconSystemName: "dollarsign.circle.fill", coinGeckoID: "dai")
    }
}
