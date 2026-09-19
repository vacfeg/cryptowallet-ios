import Foundation
import WalletCore

/// Builds and locally signs EVM transactions via WalletCore's Ethereum
/// signer. Deliberately uses legacy (type-0) transactions rather than
/// EIP-1559 — every EVM chain in this app still accepts them, and it keeps
/// this file to WalletCore's stable, long-documented `EthereumSigningInput`
/// fields (chainID/nonce/gasPrice/gasLimit) instead of the newer
/// fee-market-specific ones, which have shifted across WalletCore releases.
///
/// NOTE: this is the one file in the app whose exact protobuf field names
/// should be re-checked against whatever WalletCore version Swift Package
/// Manager resolves (see README "What to verify on first build") — it's
/// the highest-risk integration point in a project written without a
/// working Xcode toolchain to compile against.
enum EVMTransactionSigner {

    static func signNativeTransfer(
        request: TransactionRequest,
        chainID: Int,
        nonce: UInt64,
        gas: GasEstimate,
        privateKey: SecureBytes
    ) throws -> SignedTransaction {
        let amountHex = BigNumber.rawHex(fromTokenAmount: request.amount, decimals: request.assetDecimals)
        guard let amountData = Data(hex: amountHex) else { throw ProviderError.signingFailed }

        let input = EthereumSigningInput.with {
            $0.chainID = bigEndianData(from: chainID)
            $0.nonce = bigEndianData(from: nonce)
            $0.gasPrice = decimalToData(gas.gasPrice)
            $0.gasLimit = decimalToData(gas.gasLimit)
            $0.toAddress = request.toAddress
            $0.privateKey = Data(privateKey.bytes)
            $0.transaction = EthereumTransaction.with {
                $0.transfer = EthereumTransaction.Transfer.with {
                    $0.amount = amountData
                }
            }
        }

        return try sign(input: input)
    }

    static func signTokenTransfer(
        request: TransactionRequest,
        contractAddress: String,
        chainID: Int,
        nonce: UInt64,
        gas: GasEstimate,
        privateKey: SecureBytes
    ) throws -> SignedTransaction {
        guard let calldata = ERC20.transferCalldata(to: request.toAddress, amount: request.amount, decimals: request.assetDecimals) else {
            throw ProviderError.signingFailed
        }

        let input = EthereumSigningInput.with {
            $0.chainID = bigEndianData(from: chainID)
            $0.nonce = bigEndianData(from: nonce)
            $0.gasPrice = decimalToData(gas.gasPrice)
            $0.gasLimit = decimalToData(gas.gasLimit)
            $0.toAddress = contractAddress
            $0.privateKey = Data(privateKey.bytes)
            $0.transaction = EthereumTransaction.with {
                $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                    $0.amount = Data([0])
                    $0.data = calldata
                }
            }
        }

        return try sign(input: input)
    }

    private static func sign(input: EthereumSigningInput) throws -> SignedTransaction {
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)
        guard output.encoded.count > 0 else { throw ProviderError.signingFailed }
        return SignedTransaction(rawHex: output.encoded.hexPrefixed, expectedHash: nil)
    }

    private static func bigEndianData(from value: Int) -> Data {
        decimalToData(Decimal(value))
    }

    private static func bigEndianData(from value: UInt64) -> Data {
        decimalToData(Decimal(value))
    }

    /// WalletCore expects unsigned integer fields (chainID, nonce, gasPrice,
    /// gasLimit) as minimal big-endian byte arrays, not fixed-width ints.
    private static func decimalToData(_ value: Decimal) -> Data {
        var v = value
        var rounded = Decimal()
        NSDecimalRound(&rounded, &v, 0, .down)
        let hex = BigNumber.rawHex(fromTokenAmount: rounded, decimals: 0)
        return Data(hex: hex) ?? Data([0])
    }
}
