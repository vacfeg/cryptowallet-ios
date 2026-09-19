import Foundation
import WalletCore

/// Address derivation for Bitcoin is real (via WalletCore/HDWallet, same as
/// every other chain), so the wallet can show a correct receive address
/// today. Balance, fee estimation, UTXO selection, and signing are NOT
/// implemented — Bitcoin needs its own transaction model (UTXOs, not an
/// account/nonce model) and a chain-specific indexer, which is out of scope
/// for this first version. Per rule 34 ("no mockear funciones reales"), this
/// throws rather than returning a fabricated balance or transaction.
struct BitcoinProvider: BlockchainProvider {
    let network: Network

    init(network: Network) {
        precondition(network.kind == .bitcoin)
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
        CoinType.bitcoin.validate(address: address)
    }
}
