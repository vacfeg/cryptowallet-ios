import Foundation
import WalletCore

/// Same status as `BitcoinProvider`: real address derivation, no
/// balance/send yet. Solana's account model, rent-exemption rules, and
/// recent-blockhash-based signing are meaningfully different from the EVM
/// path and are left for a follow-up version rather than approximated here.
struct SolanaProvider: BlockchainProvider {
    let network: Network

    init(network: Network) {
        precondition(network.kind == .solana)
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
        CoinType.solana.validate(address: address)
    }
}
