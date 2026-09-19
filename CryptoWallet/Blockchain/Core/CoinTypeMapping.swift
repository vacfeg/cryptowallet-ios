import WalletCore

/// Maps our `NetworkKind` to WalletCore's `CoinType`, which owns the BIP-44
/// derivation path and address format for each chain family.
///
/// Every EVM network (Ethereum, Base, Arbitrum, Optimism, Polygon, BNB
/// Chain, Avalanche C-Chain, ...) shares one Ethereum-style address derived
/// at m/44'/60'/0'/0/0 — this is standard across MetaMask, Trust Wallet, and
/// every other multi-chain EVM wallet, so a single account has the same
/// address on every EVM network. Per-chain replay protection (chain ID)
/// is applied separately, at signing time, in `EVMProvider` — it is not a
/// derivation-path concern.
enum CoinTypeMapping {
    static func coinType(for kind: NetworkKind) -> CoinType {
        switch kind {
        case .evm: return .ethereum
        case .bitcoin: return .bitcoin
        case .solana: return .solana
        case .tron: return .tron
        }
    }
}
