import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    @State private var showSend = false
    @State private var showReceive = false
    @State private var showSwap = false
    @State private var showNetworkSelector = false
    @State private var selectedHolding: AssetHolding?

    private var account: WalletAccount? {
        appState.walletManager.account(kind: appState.selectedNetwork.kind)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        header

                        if viewModel.isLoading && viewModel.holdings.isEmpty {
                            SkeletonBalanceCard()
                        } else {
                            BalanceCardView(
                                totalValueUSD: viewModel.totalValueUSD,
                                change24h: viewModel.portfolioChange24h,
                                currency: appState.settings.currency,
                                isHidden: appState.settings.hideBalances,
                                onSend: { showSend = true },
                                onReceive: { showReceive = true },
                                onSwap: { showSwap = true }
                            )
                        }

                        if let error = viewModel.errorMessage {
                            ErrorBanner(message: error) {
                                Task { await refresh() }
                            }
                        }

                        assetsSection
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.top, Spacing.s)
                    .padding(.bottom, 120)
                }
                .refreshable { await refresh() }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSend) {
            SendView(network: appState.selectedNetwork, preselectedToken: nil)
        }
        .sheet(isPresented: $showReceive) {
            ReceiveView(network: appState.selectedNetwork)
        }
        .sheet(isPresented: $showSwap) {
            SwapPlaceholderView()
        }
        .sheet(isPresented: $showNetworkSelector) {
            NetworkSelectorView(embedded: false)
        }
        .sheet(item: $selectedHolding) { holding in
            AssetDetailView(holding: holding, network: appState.selectedNetwork)
        }
        .task { await refresh() }
        .onChange(of: appState.settings.selectedNetworkID) { _ in
            Task { await refresh() }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: Spacing.s) {
                ZStack {
                    Circle().fill(Theme.brandGradient).frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(appState.walletManager.activeWallet?.name ?? "Wallet")
                        .font(Typography.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Button {
                        HapticManager.selectionChanged()
                        showNetworkSelector = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(appState.selectedNetwork.name)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)
                    }
                }
            }

            Spacer()

            Button {
                appState.settings.hideBalances.toggle()
                HapticManager.tap()
            } label: {
                Image(systemName: appState.settings.hideBalances ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 36, height: 36)
                    .glassSurface(cornerRadius: Radius.pill)
            }
        }
    }

    private var assetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Your Assets")
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            if !appState.selectedNetwork.kind.isFullySupported {
                comingSoonNotice
            }

            if viewModel.isLoading && viewModel.holdings.isEmpty {
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in SkeletonAssetRow() }
                }
            } else if viewModel.holdings.isEmpty {
                EmptyStateView(icon: "tray", title: "No assets yet", message: "Assets will appear here once you receive funds.")
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.holdings) { holding in
                        Button { selectedHolding = holding } label: {
                            AssetRowView(holding: holding, currency: appState.settings.currency, isHidden: appState.settings.hideBalances)
                        }
                        .buttonStyle(.plain)
                        if holding.id != viewModel.holdings.last?.id {
                            Divider().overlay(Theme.glassBorder)
                        }
                    }
                }
                .padding(.horizontal, Spacing.m)
                .glassSurface()
            }
        }
    }

    private var comingSoonNotice: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "hourglass")
                .foregroundStyle(Theme.textTertiary)
            Text("Balances and sending on \(appState.selectedNetwork.name) are coming soon. Your receive address is available now.")
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(Spacing.m)
        .glassSurface(cornerRadius: Radius.small)
    }

    private func refresh() async {
        await viewModel.load(account: account, network: appState.selectedNetwork, currency: appState.settings.currency)
    }
}

private struct SwapPlaceholderView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            EmptyStateView(
                icon: "arrow.left.arrow.right.circle",
                title: "Swap is coming soon",
                message: "We're preparing a secure way to swap assets directly in the wallet. This screen is wired up and ready to connect to an aggregator."
            )
        }
    }
}
