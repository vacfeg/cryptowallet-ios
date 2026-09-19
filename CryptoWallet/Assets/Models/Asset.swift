import Foundation

/// A token paired with the live data needed to render it: balance, price,
/// and 24h change. `balance`/`priceUSD` are `nil` while loading or if a
/// fetch failed — the view layer renders that as a skeleton or "--", never
/// as zero (which would look like a real, empty balance).
struct AssetHolding: Identifiable, Hashable {
    let token: Token
    var balance: Decimal?
    var priceUSD: Decimal?
    var change24h: Decimal?

    var id: String { token.id }

    var valueUSD: Decimal? {
        guard let balance, let priceUSD else { return nil }
        return balance * priceUSD
    }
}
