import SwiftUI

struct SecuritySettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showResetConfirm = false
    @State private var showResetAuth = false

    private var biometricName: String {
        switch BiometricAuthManager.availableBiometric {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Biometrics"
        }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.l) {
                    VStack(spacing: 0) {
                        toggleRow(title: biometricName, subtitle: "Require \(biometricName) to open the app", isOn: $appState.settings.faceIDEnabled)
                        Divider().overlay(Theme.glassBorder)
                        toggleRow(title: "Hide Balances", subtitle: "Mask amounts on the dashboard", isOn: $appState.settings.hideBalances)
                    }
                    .padding(.horizontal, Spacing.m)
                    .glassSurface()

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("Auto-Lock")
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, Spacing.xs)
                        VStack(spacing: 0) {
                            ForEach(AutoLockDuration.allCases) { duration in
                                Button {
                                    appState.settings.autoLock = duration
                                    HapticManager.selectionChanged()
                                } label: {
                                    HStack {
                                        Text(duration.title).foregroundStyle(Theme.textPrimary)
                                        Spacer()
                                        if appState.settings.autoLock == duration {
                                            Image(systemName: "checkmark").foregroundStyle(Theme.success)
                                        }
                                    }
                                    .padding(.vertical, Spacing.s)
                                }
                                if duration != AutoLockDuration.allCases.last {
                                    Divider().overlay(Theme.glassBorder)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.m)
                        .glassSurface()
                    }

                    if let wallet = appState.walletManager.activeWallet {
                        HStack(spacing: Spacing.s) {
                            Image(systemName: wallet.backupConfirmed ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                .foregroundStyle(wallet.backupConfirmed ? Theme.success : Theme.warning)
                            Text(wallet.backupConfirmed ? "Recovery phrase backed up" : "Recovery phrase not verified")
                                .font(Typography.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                        }
                        .padding(Spacing.m)
                        .glassSurface()
                    }

                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Text("Reset Wallet")
                            .font(Typography.buttonLabel)
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.m)
                            .glassSurface()
                    }
                }
                .padding(Spacing.l)
            }
        }
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "This removes the wallet from this device. Make sure you've saved your recovery phrase — it's the only way to restore it.",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset Wallet", role: .destructive) {
                Task { await confirmReset() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func confirmReset() async {
        let result = await BiometricAuthManager.authenticate(reason: "Confirm you want to reset this wallet")
        guard case .success = result, let walletID = appState.walletManager.activeWallet?.id else { return }
        appState.walletManager.resetWallet(walletID: walletID)
        HapticManager.warning()
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Typography.body).foregroundStyle(Theme.textPrimary)
                Text(subtitle).font(Typography.caption).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(Theme.violet)
        }
        .padding(.vertical, Spacing.s)
    }
}
