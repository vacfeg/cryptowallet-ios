import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ForEach(AppearanceMode.allCases) { mode in
                    Button {
                        appState.settings.appearance = mode
                        HapticManager.selectionChanged()
                    } label: {
                        HStack {
                            Text(mode.title).foregroundStyle(Theme.textPrimary)
                            Spacer()
                            if appState.settings.appearance == mode {
                                Image(systemName: "checkmark").foregroundStyle(Theme.success)
                            }
                        }
                        .padding(.vertical, Spacing.m)
                    }
                    if mode != AppearanceMode.allCases.last {
                        Divider().overlay(Theme.glassBorder)
                    }
                }
            }
            .padding(.horizontal, Spacing.m)
            .glassSurface()
            .padding(Spacing.l)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
