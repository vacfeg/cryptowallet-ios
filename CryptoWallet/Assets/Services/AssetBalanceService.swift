import Foundation

/// Fetches balances + prices for a network's token list and merges them
/// into `AssetHolding`s. A single token failing to load never blocks the
/// rest — each fetch is isolated so one bad RPC call can't blank the whole
/// dashboard.
struct AssetBalanceService {
    private let priceProvider: PriceProvider
    private let priceCache = PriceCache()
    private let customTokenStore = CustomTokenStore()

    init(priceProvider: PriceProvider = CoinGeckoPriceProvider()) {
        self.priceProvider = priceProvider
    }

    func holdings(for account: WalletAccount, network: Network, currency: FiatCurrency) async -> [AssetHolding] {
        guard network.kind.isFullySupported else {
            // Bitcoin/Solana/Tron: show the native asset with the address
            // available but no balance data — never a fabricated number.
            return [AssetHolding(token: TokenList.nativeToken(for: network), balance: nil, priceUSD: nil, change24h: nil)]
        }

        let provider = BlockchainProviderFactory.provider(for: network)
        let tokens = TokenList.defaultTokens(for: network) + customTokenStore.tokens(for: network.id)

        let balances = await withTaskGroup(of: (Token, Decimal?).self) { group -> [String: Decimal] in
            for token in tokens {
                group.addTask {
                    let balance = try? await fetchBalance(token: token, address: account.address, provider: provider)
                    return (token, balance)
                }
            }
            var result: [String: Decimal] = [:]
            for await (token, balance) in group {
                result[token.id] = balance
            }
            return result
        }

        let coinGeckoIDs = tokens.compactMap(\.coinGeckoID)
        let prices = (try? await priceProvider.prices(ids: coinGeckoIDs, currency: currency)) ?? [:]
        if !prices.isEmpty { priceCache.save(prices) }

        return tokens.map { token in
            let livePrice = token.coinGeckoID.flatMap { prices[$0] }
            let cached = livePrice == nil ? token.coinGeckoID.flatMap { priceCache.price(for: $0)?.point } : nil
            let point = livePrice ?? cached
            return AssetHolding(
                token: token,
                balance: balances[token.id] ?? nil,
                priceUSD: point?.usd,
                change24h: point?.change24h
            )
        }
    }

    private func fetchBalance(token: Token, address: String, provider: BlockchainProvider) async throws -> Decimal {
        if let contractAddress = token.contractAddress {
            return try await provider.tokenBalance(address: address, contractAddress: contractAddress, decimals: token.decimals)
        } else {
            return try await provider.nativeBalance(address: address)
        }
    }

    func addCustomToken(_ token: Token) {
        customTokenStore.add(token)
    }

    func removeCustomToken(_ token: Token) {
        customTokenStore.remove(token)
    }
}

/// Persists user-added ERC-20 tokens (rule 5: "Agregar tokens").
struct CustomTokenStore {
    private let store = LocalStore()

    func tokens(for networkID: String) -> [Token] {
        all().filter { $0.networkID == networkID }
    }

    func add(_ token: Token) {
        var current = all()
        guard !current.contains(token) else { return }
        current.append(token)
        store.save(current, key: StorageKey.customTokens)
    }

    func remove(_ token: Token) {
        var current = all()
        current.removeAll { $0.id == token.id }
        store.save(current, key: StorageKey.customTokens)
    }

    private func all() -> [Token] {
        store.load([Token].self, key: StorageKey.customTokens) ?? []
    }
}
