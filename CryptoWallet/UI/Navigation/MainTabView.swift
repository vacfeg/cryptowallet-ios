import SwiftUI

struct MainTabView: View {
    @State private var selection: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home: DashboardView()
                case .activity: ActivityView()
                case .explore: NetworkSelectorView(embedded: true)
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GlassTabBar(selection: $selection)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
    }
}
