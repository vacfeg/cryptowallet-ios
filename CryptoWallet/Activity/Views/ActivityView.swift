import SwiftUI

private enum ActivityFilter: String, CaseIterable, Identifiable {
    case all = "All", sent = "Sent", received = "Received"
    var id: String { rawValue }
}

struct ActivityView: View {
    @EnvironmentObject private var appState: AppState
    @State private var transactions: [WalletTransaction] = []
    @State private var filter: ActivityFilter = .all
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var filtered: [WalletTransaction] {
        switch filter {
        case .all: return transactions
        case .sent: return transactions.filter { $0.direction == .sent }
        case .received: return transactions.filter { $0.direction == .received }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.l) {
                        Text("Activity")
                            .font(Typography.largeTitle)
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker("Filter", selection: $filter) {
                            ForEach(ActivityFilter.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)

                        if let errorMessage {
                            ErrorBanner(message: errorMessage) { Task { await load() } }
                        }

                        if isLoading {
                            VStack(spacing: Spacing.s) { ForEach(0..<4, id: \.self) { _ in SkeletonAssetRow() } }
                        } else if filtered.isEmpty {
                            EmptyStateView(icon: "clock.arrow.circlepath", title: "No activity yet", message: "Your transactions on \(appState.selectedNetwork.name) will show up here.")
                                .padding(.top, Spacing.xxl)
                        } else {
                            VStack(spacing: Spacing.xs) {
                                ForEach(filtered) { tx in
                                    TransactionRowView(transaction: tx, network: appState.selectedNetwork)
                                }
                            }
                        }
                    }
                    .padding(Spacing.l)
                    .padding(.bottom, 120)
                }
                .refreshable { await load() }
            }
            .navigationBarHidden(true)
        }
        .task { await load() }
        .onChange(of: appState.settings.selectedNetworkID) { _ in Task { await load() } }
    }

    private func load() async {
        guard let account = appState.walletManager.account(kind: appState.selectedNetwork.kind) else { return }
        guard appState.selectedNetwork.kind.isFullySupported else {
            transactions = []
            isLoading = false
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            transactions = try await EVMExplorerTransactionProvider().transactions(address: account.address, network: appState.selectedNetwork)
        } catch {
            transactions = []
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Couldn't load your activity."
        }
        isLoading = false
    }
}
