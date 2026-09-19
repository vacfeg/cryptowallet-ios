import Foundation

/// Everything needed to build and sign a transfer, gathered by the Send flow
/// before the user reviews and confirms it. `contractAddress == nil` means a
/// native-asset transfer; otherwise this is an ERC-20-style token transfer.
struct TransactionRequest: Equatable {
    let network: Network
    let fromAddress: String
    let toAddress: String
    let amount: Decimal
    let assetDecimals: Int
    let contractAddress: String?
}

struct GasEstimate: Equatable {
    /// Raw gas units, e.g. 21000 for a plain ETH transfer.
    let gasLimit: Decimal
    /// Wei-denominated gas price (legacy) or max fee per gas (EIP-1559).
    let gasPrice: Decimal
    let nativeDecimals: Int

    var feeInNativeUnits: Decimal {
        let divisor = pow(Decimal(10), nativeDecimals)
        return (gasLimit * gasPrice) / divisor
    }
}

struct SignedTransaction: Equatable {
    let rawHex: String
    let expectedHash: String?
}

struct BroadcastResult: Equatable {
    let transactionHash: String
}
