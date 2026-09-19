import Foundation
import Combine

// Not `@MainActor` — see the note on `AppState` for why.
final class SendViewModel: ObservableObject {
    @Published var recipientAddress = ""
    @Published var amountText = ""
    @Published var selectedToken: Token
    @Published private(set) var availableBalance: Decimal?
    @Published private(set) var gasEstimate: GasEstimate?
    @Published private(set) var isEstimatingFee = false
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var broadcastResult: BroadcastResult?

    let network: Network
    let account: WalletAccount

    private let balanceService = AssetBalanceService()

    init(network: Network, account: WalletAccount, initialToken: Token) {
        self.network = network
        self.account = account
        self.selectedToken = initialToken
    }

    var amount: Decimal? {
        guard let value = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) else { return nil }
        return value > 0 ? value : nil
    }

    var isValidAddress: Bool {
        BlockchainProviderFactory.provider(for: network).isValid(address: recipientAddress)
    }

    var isValidAmount: Bool {
        guard let amount, let availableBalance else { return false }
        let fee = gasEstimate?.feeInNativeUnits ?? 0
        let reserveForFee = selectedToken.isNative ? fee : 0
        return amount + reserveForFee <= availableBalance
    }

    var canReview: Bool {
        isValidAddress && isValidAmount && amount != nil && gasEstimate != nil
    }

    var totalNativeCost: Decimal {
        (selectedToken.isNative ? (amount ?? 0) : 0) + (gasEstimate?.feeInNativeUnits ?? 0)
    }

    func loadBalance() async {
        let holdings = await balanceService.holdings(for: account, network: network, currency: .usd)
        availableBalance = holdings.first { $0.token.id == selectedToken.id }?.balance
    }

    func estimateFee() async {
        guard isValidAddress, let amount else {
            gasEstimate = nil
            return
        }
        isEstimatingFee = true
        defer { isEstimatingFee = false }

        let request = TransactionRequest(
            network: network, fromAddress: account.address, toAddress: recipientAddress,
            amount: amount, assetDecimals: selectedToken.decimals, contractAddress: selectedToken.contractAddress
        )
        do {
            gasEstimate = try await BlockchainProviderFactory.provider(for: network).estimateFee(for: request)
        } catch {
            gasEstimate = nil
        }
    }

    /// Signs and broadcasts. Biometric confirmation happens implicitly:
    /// deriving the private key reads the Keychain item that's protected by
    /// `SecAccessControl(.biometryCurrentSet)`, so the system Face ID/Touch
    /// ID sheet appears right here before anything is signed.
    func send(walletManager: WalletManager) async {
        guard let amount, let gasEstimate, let walletID = walletManager.activeWallet?.id else { return }
        isSending = true
        errorMessage = nil

        let request = TransactionRequest(
            network: network, fromAddress: account.address, toAddress: recipientAddress,
            amount: amount, assetDecimals: selectedToken.decimals, contractAddress: selectedToken.contractAddress
        )

        do {
            let provider = BlockchainProviderFactory.provider(for: network)
            let nonce = try await provider.nonce(for: account.address)
            let privateKey = try await walletManager.privateKey(for: account, walletID: walletID)
            defer { privateKey.wipe() }

            let signed = try provider.sign(request, nonce: nonce, gas: gasEstimate, privateKey: privateKey)
            let result = try await provider.broadcast(signed)
            broadcastResult = result
            HapticManager.success()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "We couldn't send that transaction."
            HapticManager.error()
        }
        isSending = false
    }
}
