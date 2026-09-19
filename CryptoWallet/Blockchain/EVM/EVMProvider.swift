import Foundation
import WalletCore

/// Real `BlockchainProvider` implementation for Ethereum and every other
/// EVM network the app supports — the RPC calls are identical across all of
/// them (JSON-RPC 2.0), only `network.rpcURL` and `network.chainID` change.
struct EVMProvider: BlockchainProvider {
    let network: Network
    private let rpc: JSONRPCClient

    init(network: Network) {
        precondition(network.kind == .evm, "EVMProvider requires an EVM network")
        self.network = network
        self.rpc = JSONRPCClient(endpoint: network.rpcURL ?? URL(string: "https://ethereum-rpc.publicnode.com")!)
    }

    func nativeBalance(address: String) async throws -> Decimal {
        do {
            let hex: String = try await rpc.call("eth_getBalance", params: [AnyEncodable(address), AnyEncodable("latest")], as: String.self)
            return BigNumber.tokenAmount(rawHex: hex, decimals: network.decimals)
        } catch {
            throw ProviderError.network(APIError.from(error))
        }
    }

    func tokenBalance(address: String, contractAddress: String, decimals: Int) async throws -> Decimal {
        guard let calldata = ERC20.balanceOfCalldata(owner: address) else { throw ProviderError.invalidAddress }
        let callObject = EVMCallObject(to: contractAddress, data: calldata)
        do {
            let hex: String = try await rpc.call("eth_call", params: [AnyEncodable(callObject), AnyEncodable("latest")], as: String.self)
            return BigNumber.tokenAmount(rawHex: hex, decimals: decimals)
        } catch {
            throw ProviderError.network(APIError.from(error))
        }
    }

    func estimateFee(for request: TransactionRequest) async throws -> GasEstimate {
        do {
            let gasPriceHex: String = try await rpc.call("eth_gasPrice", as: String.self)
            let gasPrice = BigNumber.decimal(fromHex: gasPriceHex)

            // A plain native transfer is always 21000 gas; a token transfer
            // needs a real estimate since it depends on the contract.
            let gasLimit: Decimal
            if let contractAddress = request.contractAddress,
               let calldata = ERC20.transferCalldata(to: request.toAddress, amount: request.amount, decimals: request.assetDecimals) {
                let callObject = EVMCallObject(to: contractAddress, from: request.fromAddress, data: calldata.hexPrefixed)
                let estimateHex: String = try await rpc.call("eth_estimateGas", params: [AnyEncodable(callObject)], as: String.self)
                // Add a 20% buffer — estimates are frequently tight on
                // contracts with non-trivial logic (fee-on-transfer tokens,
                // proxies), and an under-estimated gas limit fails on-chain.
                gasLimit = BigNumber.decimal(fromHex: estimateHex) * Decimal(1.2)
            } else {
                gasLimit = 21000
            }

            return GasEstimate(gasLimit: gasLimit, gasPrice: gasPrice, nativeDecimals: network.decimals)
        } catch {
            throw ProviderError.network(APIError.from(error))
        }
    }

    func sign(_ request: TransactionRequest, nonce: UInt64, gas: GasEstimate, privateKey: SecureBytes) throws -> SignedTransaction {
        guard let chainID = network.chainID else { throw ProviderError.unsupportedNetwork }
        if let contractAddress = request.contractAddress {
            return try EVMTransactionSigner.signTokenTransfer(request: request, contractAddress: contractAddress, chainID: chainID, nonce: nonce, gas: gas, privateKey: privateKey)
        } else {
            return try EVMTransactionSigner.signNativeTransfer(request: request, chainID: chainID, nonce: nonce, gas: gas, privateKey: privateKey)
        }
    }

    func nonce(for address: String) async throws -> UInt64 {
        do {
            let hex: String = try await rpc.call("eth_getTransactionCount", params: [AnyEncodable(address), AnyEncodable("pending")], as: String.self)
            return UInt64(hex.dropFirst(2), radix: 16) ?? 0
        } catch {
            throw ProviderError.network(APIError.from(error))
        }
    }

    func broadcast(_ signed: SignedTransaction) async throws -> BroadcastResult {
        do {
            let hash: String = try await rpc.call("eth_sendRawTransaction", params: [AnyEncodable(signed.rawHex)], as: String.self)
            return BroadcastResult(transactionHash: hash)
        } catch {
            throw ProviderError.network(APIError.from(error))
        }
    }

    func isValid(address: String) -> Bool {
        var hex = address
        guard hex.hasPrefix("0x") else { return false }
        hex.removeFirst(2)
        guard hex.count == 40 else { return false }
        return hex.allSatisfy(\.isHexDigit)
    }
}

private struct EVMCallObject: Encodable {
    let to: String
    var from: String? = nil
    let data: String
}
