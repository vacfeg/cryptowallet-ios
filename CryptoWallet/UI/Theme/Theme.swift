import SwiftUI

/// Central color + gradient palette. Every semantic color adapts to
/// light/dark automatically via `UIColor { trait in ... }`, so views never
/// branch on `colorScheme` just to pick a color — dark is the primary,
/// carefully-designed mode; light gets its own tuned palette, not an
/// inverted background.
enum Theme {

    // MARK: Backgrounds

    static let background = Color(dynamic: UIColor(
        light: UIColor(hex: "#F4F5FA"),
        dark: UIColor(hex: "#06070D")
    ))

    static let backgroundElevated = Color(dynamic: UIColor(
        light: UIColor(hex: "#FFFFFF"),
        dark: UIColor(hex: "#0D0F1A")
    ))

    /// Base tint for glass surfaces, layered under `.ultraThinMaterial` /
    /// Liquid Glass so cards keep a consistent tone across both.
    static let glassTint = Color(dynamic: UIColor(
        light: UIColor(hex: "#FFFFFF").withAlphaComponent(0.55),
        dark: UIColor(hex: "#151A2E").withAlphaComponent(0.45)
    ))

    static let glassBorder = Color(dynamic: UIColor(
        light: UIColor(hex: "#1A1B2E").withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.10)
    ))

    // MARK: Text

    static let textPrimary = Color(dynamic: UIColor(
        light: UIColor(hex: "#12131C"),
        dark: UIColor(hex: "#F5F6FA")
    ))

    static let textSecondary = Color(dynamic: UIColor(
        light: UIColor(hex: "#5A5C72"),
        dark: UIColor(hex: "#9497B3")
    ))

    static let textTertiary = Color(dynamic: UIColor(
        light: UIColor(hex: "#9496A8"),
        dark: UIColor(hex: "#5E6180")
    ))

    // MARK: Brand / accents

    static let indigo = Color(hex: "#6C5CE7")
    static let violet = Color(hex: "#8B5CF6")
    static let blue = Color(hex: "#3B82F6")
    static let cyan = Color(hex: "#22D3EE")

    static let success = Color(hex: "#2ED47A")
    static let danger = Color(hex: "#FF5C72")
    static let warning = Color(hex: "#FFB020")

    // MARK: Gradients

    static let brandGradient = LinearGradient(
        colors: [blue, indigo, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let balanceCardGradient = LinearGradient(
        colors: [Color(hex: "#1B2145"), Color(hex: "#2A1B45"), Color(hex: "#151833")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroBackgroundGradient = RadialGradient(
        colors: [violet.opacity(0.35), blue.opacity(0.12), .clear],
        center: .top,
        startRadius: 10,
        endRadius: 420
    )

    static func changeColor(_ value: Decimal?) -> Color {
        guard let value else { return textSecondary }
        if value > 0 { return success }
        if value < 0 { return danger }
        return textSecondary
    }
}

enum Radius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let pill: CGFloat = 999
}

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

private extension Color {
    init(dynamic uiColor: UIColor) {
        self.init(uiColor)
    }
}

private extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }

    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
