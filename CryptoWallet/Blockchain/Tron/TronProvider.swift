import Foundation
import WalletCore

/// Same status as `BitcoinProvider`/`SolanaProvider`: real address
/// derivation only. Tron's resource model (bandwidth/energy) and its
/// HTTP-based (not JSON-RPC) node API are left for a follow-up version.
struct TronProvider: BlockchainProvider {
    let network: Network

    init(network: Network) {
        precondition(network.kind == .tron)
        self.network = network
    }

    func nativeBalance(address: String) async throws -> Decimal { throw ProviderError.notYetImplemented }
    func tokenBalance(address: String, contractAddress: String, decimals: Int) async throws -> Decimal { throw ProviderError.notYetImplemented }
    func estimateFee(for request: TransactionRequest) async throws -> GasEstimate { throw ProviderError.notYetImplemented }
    func nonce(for address: String) async throws -> UInt64 { 0 }
    func sign(_ request: TransactionRequest, nonce: UInt64, gas: GasEstimate, privateKey: SecureBytes) throws -> SignedTransaction {
        throw ProviderError.notYetImplemented
    }
    func broadcast(_ signed: SignedTransaction) async throws -> BroadcastResult { throw ProviderError.notYetImplemented }

    func isValid(address: String) -> Bool {
        CoinType.tron.validate(address: address)
    }
}
