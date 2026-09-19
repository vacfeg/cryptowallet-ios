import Foundation

/// Which chain family a `Network` belongs to. Every adapter (address
/// derivation, signing, balance fetching) switches on this instead of
/// string-matching a symbol, so an EVM chain's ETH and a future chain's
/// native asset can never be confused with each other even if they happen
/// to share a display symbol.
enum NetworkKind: String, Codable, CaseIterable {
    case evm
    case bitcoin
    case solana
    case tron

    /// Whether this app build can actually derive addresses, fetch
    /// balances, and send on this chain today. Bitcoin/Solana/Tron ship
    /// with real address derivation (via WalletCore) but no balance/send
    /// provider yet — the UI must show "Coming soon", never fabricated
    /// data, for anything not `true` here.
    var isFullySupported: Bool {
        self == .evm
    }
}
