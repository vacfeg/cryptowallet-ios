import SwiftUI

struct AssetDetailView: View {
    let holding: AssetHolding
    let network: Network

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var transactions: [WalletTransaction] = []
    @State private var isLoadingTx = true
    @State private var showSend = false
    @State private var showReceive = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.l) {
                        VStack(spacing: Spacing.s) {
                            ZStack {
                                Circle().fill(Theme.brandGradient).frame(width: 64, height: 64)
                                Image(systemName: holding.token.iconSystemName)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Text(AmountFormatter.token(holding.balance, symbol: holding.token.symbol, maxFractionDigits: 6))
                                .font(Typography.title)
                                .foregroundStyle(Theme.textPrimary)
                            Text(AmountFormatter.fiat(holding.valueUSD, currency: appState.settings.currency))
                                .font(Typography.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.top, Spacing.m)

                        HStack(spacing: Spacing.m) {
                            SecondaryButton(title: "Send", icon: "arrow.up") { showSend = true }
                            SecondaryButton(title: "Receive", icon: "arrow.down") { showReceive = true }
                        }

                        infoCard

                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Transaction History")
                                .font(Typography.headline)
                                .foregroundStyle(Theme.textPrimary)

                            if isLoadingTx {
                                VStack(spacing: 0) { ForEach(0..<3, id: \.self) { _ in SkeletonAssetRow() } }
                            } else if transactions.isEmpty {
                                EmptyStateView(icon: "clock", title: "No transactions", message: "Activity for this asset will show up here.")
                            } else {
                                VStack(spacing: Spacing.xs) {
                                    ForEach(transactions) { tx in
                                        TransactionRowView(transaction: tx, network: network)
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.l)
                }
            }
            .navigationTitle(holding.token.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showSend) {
            SendView(network: network, preselectedToken: holding.token)
        }
        .sheet(isPresented: $showReceive) {
            ReceiveView(network: network)
        }
        .task { await loadTransactions() }
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            row("Price", AmountFormatter.fiat(holding.priceUSD, currency: appState.settings.currency))
            Divider().overlay(Theme.glassBorder)
            row("24h Change", AmountFormatter.percent(holding.change24h))
            Divider().overlay(Theme.glassBorder)
            row("Network", network.name)
            if let contract = holding.token.contractAddress {
                Divider().overlay(Theme.glassBorder)
                row("Contract", contract.truncatedAddress)
            }
        }
        .padding(.horizontal, Spacing.m)
        .glassSurface()
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(Typography.subheadline).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(Typography.subheadline.weight(.medium)).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, Spacing.s)
    }

    private func loadTransactions() async {
        guard let account = appState.walletManager.account(kind: network.kind), network.kind.isFullySupported else {
            isLoadingTx = false
            return
        }
        let provider: TransactionProvider = EVMExplorerTransactionProvider()
        let all = (try? await provider.transactions(address: account.address, network: network)) ?? []
        transactions = all.filter { tx in
            holding.token.isNative ? tx.tokenContractAddress == nil : tx.tokenContractAddress?.lowercased() == holding.token.contractAddress?.lowercased()
        }
        isLoadingTx = false
    }
}
