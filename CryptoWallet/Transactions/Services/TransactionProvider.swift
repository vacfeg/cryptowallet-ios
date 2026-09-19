import Foundation

protocol TransactionProvider {
    func transactions(address: String, network: Network) async throws -> [WalletTransaction]
}

/// Real transaction history for EVM networks via Etherscan's unified V2 API,
/// which covers Ethereum and every other Etherscan-family explorer
/// (Basescan, Arbiscan, Polygonscan, BscScan, Snowtrace, ...) through one
/// endpoint keyed by `chainid`. Requires `EXPLORER_API_KEY` in
/// `Secrets.xcconfig` — without one, this throws and the Activity screen
/// shows its "check your connection" empty state rather than silently
/// returning nothing typed as success.
struct EVMExplorerTransactionProvider: TransactionProvider {
    private let http = HTTPClient()

    private struct Response: Decodable {
        let status: String
        let result: [Entry]
    }

    private struct Entry: Decodable {
        let hash: String
        let from: String
        let to: String
        let value: String
        let timeStamp: String
        let isError: String
        let tokenSymbol: String?
        let contractAddress: String?
        let tokenDecimal: String?
    }

    func transactions(address: String, network: Network) async throws -> [WalletTransaction] {
        guard network.kind == .evm, let chainID = network.chainID else { throw ProviderError.unsupportedNetwork }
        guard let apiKey = AppConfig.explorerAPIKey else { throw ProviderError.notYetImplemented }

        var components = URLComponents(string: "https://api.etherscan.io/v2/api")!
        components.queryItems = [
            URLQueryItem(name: "chainid", value: "\(chainID)"),
            URLQueryItem(name: "module", value: "account"),
            URLQueryItem(name: "action", value: "txlist"),
            URLQueryItem(name: "address", value: address),
            URLQueryItem(name: "sort", value: "desc"),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        guard let url = components.url else { throw APIError.invalidResponse }

        let response = try await http.getJSON(url, as: Response.self)
        let lowerAddress = address.lowercased()

        return response.result.compactMap { entry -> WalletTransaction? in
            guard let timestamp = TimeInterval(entry.timeStamp) else { return nil }
            let decimals = Int(entry.tokenDecimal ?? "") ?? network.decimals
            let amount = BigNumber.tokenAmount(rawHex: hexOrDecimal(entry.value), decimals: decimals)
            let direction: TransactionDirection = entry.from.lowercased() == lowerAddress ? .sent : .received
            let status: TransactionStatus = entry.isError == "1" ? .failed : .confirmed

            return WalletTransaction(
                hash: entry.hash,
                networkID: network.id,
                direction: direction,
                status: status,
                counterpartyAddress: direction == .sent ? entry.to : entry.from,
                amount: amount,
                symbol: entry.tokenSymbol ?? network.symbol,
                timestamp: Date(timeIntervalSince1970: timestamp),
                tokenContractAddress: entry.contractAddress?.isEmpty == false ? entry.contractAddress : nil
            )
        }
    }

    /// Etherscan's `txlist` returns `value` as a plain decimal string, not
    /// "0x"-prefixed hex like JSON-RPC — normalize so `BigNumber` can parse
    /// either.
    private func hexOrDecimal(_ value: String) -> String {
        if value.hasPrefix("0x") { return value }
        guard let intValue = Decimal(string: value) else { return "0x0" }
        return BigNumber.rawHex(fromTokenAmount: intValue, decimals: 0)
    }
}
