import SwiftUI

struct ReviewSendView: View {
    @ObservedObject var viewModel: SendViewModel
    let currency: FiatCurrency
    let onFinished: () -> Void

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                if let result = viewModel.broadcastResult {
                    SendSuccessView(network: viewModel.network, result: result) {
                        onFinished()
                    }
                } else {
                    reviewContent
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.broadcastResult == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") { dismiss() }.foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isSending)
        }
    }

    private var reviewContent: some View {
        VStack(spacing: Spacing.l) {
            VStack(spacing: 0) {
                row("Asset", "\(viewModel.selectedToken.symbol) · \(viewModel.network.name)")
                Divider().overlay(Theme.glassBorder)
                row("Amount", AmountFormatter.token(viewModel.amount, symbol: viewModel.selectedToken.symbol))
                Divider().overlay(Theme.glassBorder)
                row("Recipient", viewModel.recipientAddress.truncatedAddress)
                Divider().overlay(Theme.glassBorder)
                row("Network Fee", AmountFormatter.token(viewModel.gasEstimate?.feeInNativeUnits, symbol: viewModel.network.symbol))
                Divider().overlay(Theme.glassBorder)
                row("Total", totalText, emphasized: true)
            }
            .padding(.horizontal, Spacing.m)
            .glassSurface()
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.l)

            if let error = viewModel.errorMessage {
                ErrorBanner(message: error)
                    .padding(.horizontal, Spacing.l)
            }

            Spacer()

            PrimaryButton(title: "Confirm Send", isLoading: viewModel.isSending) {
                Task { await viewModel.send(walletManager: appState.walletManager) }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var totalText: String {
        let native = viewModel.totalNativeCost
        if viewModel.selectedToken.isNative {
            return AmountFormatter.token(native, symbol: viewModel.network.symbol)
        }
        let amount = AmountFormatter.token(viewModel.amount, symbol: viewModel.selectedToken.symbol)
        let fee = AmountFormatter.token(viewModel.gasEstimate?.feeInNativeUnits, symbol: viewModel.network.symbol)
        return "\(amount) + \(fee) fee"
    }

    private func row(_ label: String, _ value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(label).font(Typography.subheadline).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(emphasized ? Typography.subheadline.weight(.bold) : Typography.subheadline.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, Spacing.s)
    }
}
