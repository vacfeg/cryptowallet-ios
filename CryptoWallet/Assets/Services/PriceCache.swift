import Foundation

/// Persists the last successfully-fetched prices so the dashboard can show
/// real (if stale) numbers offline instead of "--" everywhere (rule 37/10).
struct PriceCache {
    private let store = LocalStore()

    private struct CachedEntry: Codable {
        let point: PricePoint
        let fetchedAt: Date
    }

    func save(_ prices: [String: PricePoint]) {
        let now = Date()
        var cache = load()
        for (id, point) in prices {
            cache[id] = CachedEntry(point: point, fetchedAt: now)
        }
        store.save(cache, key: StorageKey.priceCache)
    }

    func price(for id: String) -> (point: PricePoint, isStale: Bool)? {
        guard let entry = load()[id] else { return nil }
        let isStale = Date().timeIntervalSince(entry.fetchedAt) > 900 // 15 minutes
        return (entry.point, isStale)
    }

    private func load() -> [String: CachedEntry] {
        store.load([String: CachedEntry].self, key: StorageKey.priceCache) ?? [:]
    }
}
