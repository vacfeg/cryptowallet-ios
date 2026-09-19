import SwiftUI

struct SendView: View {
    let network: Network
    let preselectedToken: Token?

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SendViewModelBox
    @State private var showScanner = false
    @State private var showReview = false
    @FocusState private var amountFocused: Bool

    init(network: Network, preselectedToken: Token?) {
        self.network = network
        self.preselectedToken = preselectedToken
        _viewModel = StateObject(wrappedValue: SendViewModelBox())
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                if let vm = viewModel.vm {
                    content(vm)
                } else {
                    ProgressView().tint(Theme.textPrimary)
                }
            }
            .navigationTitle("Send")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Theme.textPrimary)
                }
            }
        }
        .task {
            guard viewModel.vm == nil, let account = appState.walletManager.account(kind: network.kind) else { return }
            let token = preselectedToken ?? TokenList.nativeToken(for: network)
            let vm = SendViewModel(network: network, account: account, initialToken: token)
            viewModel.vm = vm
            await vm.loadBalance()
        }
    }

    @ViewBuilder
    private func content(_ vm: SendViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                recipientField(vm)
                amountField(vm)
                feeSummary(vm)
                Spacer(minLength: Spacing.xl)
            }
            .padding(Spacing.l)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                PrimaryButton(title: "Review Transaction", isDisabled: !vm.canReview) {
                    showReview = true
                }
            }
            .padding(Spacing.l)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView { scanned in vm.recipientAddress = scanned }
        }
        .sheet(isPresented: $showReview) {
            ReviewSendView(viewModel: vm, currency: appState.settings.currency) {
                dismiss()
            }
        }
        .task(id: "\(vm.recipientAddress)-\(vm.amountText)-\(vm.selectedToken.id)") {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await vm.estimateFee()
        }
        .onTapGesture { amountFocused = false }
    }

    private func recipientField(_ vm: SendViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Recipient")
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            HStack {
                TextField("Address or ENS", text: Binding(get: { vm.recipientAddress }, set: { vm.recipientAddress = $0 }))
                    .font(Typography.monoSmall)
                    .foregroundStyle(Theme.textPrimary)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                Button { showScanner = true } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(Spacing.m)
            .glassSurface(cornerRadius: Radius.medium)

            if !vm.recipientAddress.isEmpty && !vm.isValidAddress {
                Text("That doesn't look like a valid \(network.name) address.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.danger)
            }
        }
    }

    private func amountField(_ vm: SendViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("Amount")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                if let balance = vm.availableBalance {
                    Text("Balance: \(AmountFormatter.token(balance, symbol: vm.selectedToken.symbol))")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            HStack {
                TextField("0.0", text: Binding(get: { vm.amountText }, set: { vm.amountText = $0 }))
                    .keyboardType(.decimalPad)
                    .font(Typography.title)
                    .foregroundStyle(Theme.textPrimary)
                    .focused($amountFocused)
                Text(vm.selectedToken.symbol)
                    .font(Typography.headline)
                    .foregroundStyle(Theme.textSecondary)
                Button("Max") {
                    if let balance = vm.availableBalance {
                        let fee = vm.selectedToken.isNative ? (vm.gasEstimate?.feeInNativeUnits ?? 0) : 0
                        let max = balance - fee
                        vm.amountText = "\(Swift.max(max, 0))"
                    }
                }
                .font(Typography.caption.weight(.semibold))
                .foregroundStyle(Theme.blue)
            }
            .padding(Spacing.m)
            .glassSurface(cornerRadius: Radius.medium)

            if let amount = vm.amount, vm.availableBalance != nil, !vm.isValidAmount {
                Text("Amount exceeds your available balance\(vm.selectedToken.isNative ? " plus network fee" : "").")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.danger)
                    .id(amount)
            }
        }
    }

    private func feeSummary(_ vm: SendViewModel) -> some View {
        HStack {
            Text("Estimated network fee")
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            if vm.isEstimatingFee {
                ProgressView().tint(Theme.textSecondary)
            } else if let gas = vm.gasEstimate {
                Text(AmountFormatter.token(gas.feeInNativeUnits, symbol: network.symbol))
                    .font(Typography.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
            } else {
                Text("--").foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(Spacing.m)
        .glassSurface(cornerRadius: Radius.medium)
    }
}

/// SwiftUI needs a stable `@StateObject` even though the real view model
/// can only be constructed once the account is known (inside `.task`) —
/// this box gives it somewhere to live without force-unwrapping.
private final class SendViewModelBox: ObservableObject {
    @Published var vm: SendViewModel?
}
