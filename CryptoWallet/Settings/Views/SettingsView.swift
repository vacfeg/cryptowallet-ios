import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.l) {
                        Text("Settings")
                            .font(Typography.largeTitle)
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        walletHeader

                        groupedSection(items: [
                            navRow(icon: "lock.shield.fill", title: "Security") { SecuritySettingsView() },
                            navRow(icon: "network", title: "Networks") { NetworkSelectorView(embedded: true) },
                            navRow(icon: "creditcard.fill", title: "Assets") { AssetsSettingsView() }
                        ])

                        groupedSection(items: [
                            navRow(icon: "paintbrush.fill", title: "Appearance") { AppearanceSettingsView() },
                            navRow(icon: "dollarsign.circle.fill", title: "Currency") { CurrencySettingsView() },
                            navRow(icon: "bell.fill", title: "Notifications") { NotificationsSettingsView() }
                        ])

                        groupedSection(items: [
                            navRow(icon: "info.circle.fill", title: "About") { AboutView() }
                        ])
                    }
                    .padding(Spacing.l)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var walletHeader: some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle().fill(Theme.brandGradient).frame(width: 52, height: 52)
                Image(systemName: "person.fill").foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(appState.walletManager.activeWallet?.name ?? "Wallet")
                    .font(Typography.headline)
                    .foregroundStyle(Theme.textPrimary)
                if let account = appState.walletManager.account(kind: .evm) {
                    Text(account.address.truncatedAddress)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(Spacing.m)
        .glassSurface(elevated: true)
    }

    private func groupedSection(items: [AnyView]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                item
                if index != items.count - 1 {
                    Divider().overlay(Theme.glassBorder).padding(.leading, 52)
                }
            }
        }
        .padding(.horizontal, Spacing.m)
        .glassSurface(elevated: true)
    }

    private func navRow<Destination: View>(icon: String, title: String, @ViewBuilder destination: () -> Destination) -> AnyView {
        AnyView(
            NavigationLink {
                destination()
            } label: {
                HStack(spacing: Spacing.m) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 28)
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(.vertical, Spacing.m)
            }
            .buttonStyle(.plain)
        )
    }
}
