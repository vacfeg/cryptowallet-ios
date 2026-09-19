import SwiftUI

struct NetworkSelectorView: View {
    /// `embedded` when hosted as the "Explore" tab (no Done button, no
    /// sheet chrome) vs. presented as a modal picker from the dashboard.
    let embedded: Bool

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            // Conditional `ToolbarContent` inside a single `.toolbar { }`
            // needs iOS 16's `buildIf` — split into two whole branches
            // instead, which works back to iOS 13.
            if embedded {
                screenBody
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            } else {
                screenBody
                    .navigationTitle("Select Network")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { dismiss() }.foregroundStyle(Theme.textPrimary)
                        }
                    }
            }
        }
    }

    private var screenBody: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.l) {
                    if embedded {
                        Text("Explore Networks")
                            .font(Typography.largeTitle)
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    section(title: "EVM Networks", networks: SupportedNetworks.evmNetworks)
                    section(title: "Coming Soon", networks: SupportedNetworks.previewOnlyNetworks)
                }
                .padding(Spacing.l)
                .padding(.bottom, 120)
            }
        }
    }

    private func section(title: String, networks: [Network]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(Typography.headline)
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: Spacing.xs) {
                ForEach(networks) { network in
                    networkRow(network)
                }
            }
        }
    }

    private func networkRow(_ network: Network) -> some View {
        let isSelected = appState.settings.selectedNetworkID == network.id
        return Button {
            HapticManager.mediumImpact()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                appState.selectNetwork(network)
            }
            if !embedded { dismiss() }
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle().fill(Theme.glassTint).frame(width: 36, height: 36)
                    Image(systemName: network.iconSystemName)
                        .foregroundStyle(Theme.textPrimary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(network.name).font(Typography.body.weight(.medium)).foregroundStyle(Theme.textPrimary)
                    Text(network.kind.isFullySupported ? "Chain ID \(network.chainID.map(String.init) ?? "--")" : "Address only")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.success)
                }
            }
            .padding(Spacing.m)
            .glassSurface(cornerRadius: Radius.medium, tint: isSelected ? Theme.glassTint : Theme.glassTint.opacity(0.5))
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.97))
    }
}
