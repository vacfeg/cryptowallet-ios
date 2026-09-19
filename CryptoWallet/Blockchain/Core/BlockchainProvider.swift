import Foundation

/// The interface every chain adapter implements. The rest of the app
/// (ViewModels, Send/Receive screens) talks only to this protocol, never to
/// `EVMProvider` or a future `SolanaProvider` directly — swapping an RPC
/// vendor, or adding a chain, never touches call sites elsewhere.
protocol BlockchainProvider {
    var network: Network { get }

    /// Native asset balance, in human units (already divided by decimals).
    func nativeBalance(address: String) async throws -> Decimal

    /// Token balance for a contract address, in human units.
    func tokenBalance(address: String, contractAddress: String, decimals: Int) async throws -> Decimal

    func estimateFee(for request: TransactionRequest) async throws -> GasEstimate

    /// The account's next sequence number (EVM nonce; unused/0 for chains
    /// without one). Fetched separately from signing so signing itself stays
    /// a synchronous, offline operation.
    func nonce(for address: String) async throws -> UInt64

    /// Signs the request locally using the account's private key. The key
    /// material never leaves this call — callers only ever see the signed,
    /// broadcast-ready payload.
    func sign(_ request: TransactionRequest, nonce: UInt64, gas: GasEstimate, privateKey: SecureBytes) throws -> SignedTransaction

    func broadcast(_ signed: SignedTransaction) async throws -> BroadcastResult

    func isValid(address: String) -> Bool
}
