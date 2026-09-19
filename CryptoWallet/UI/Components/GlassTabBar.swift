import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case home, activity, explore, settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .activity: return "Activity"
        case .explore: return "Explore"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .activity: return "clock.arrow.circlepath"
        case .explore: return "safari.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Custom floating glass tab bar, replacing a stock `TabView` so it can
/// share the same Liquid Glass material as the rest of the app (rule 28:
/// "no utilizar una TabView completamente genérica").
struct GlassTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, Spacing.s)
        .glassSurface(cornerRadius: Radius.pill, elevated: true)
        .padding(.horizontal, Spacing.l)
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selection == tab
        return Button {
            HapticManager.selectionChanged()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                            .fill(Theme.brandGradient.opacity(0.85))
                            .matchedGeometryEffect(id: "tab-highlight", in: tabNamespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    @Namespace private var tabNamespace
}
