import SwiftUI

struct NotificationsSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Push Notifications").font(Typography.body).foregroundStyle(Theme.textPrimary)
                        Text("Get notified about incoming transactions").font(Typography.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $appState.settings.notificationsEnabled).labelsHidden().tint(Theme.violet)
                }
                .padding(Spacing.m)
                .glassSurface()

                Text("This wallet has no backend, so notifications require your device to poll the network locally — this toggle is wired up but the polling service is a follow-up feature.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(Spacing.l)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
