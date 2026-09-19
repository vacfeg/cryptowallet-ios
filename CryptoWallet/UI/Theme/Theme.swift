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
    /// Liquid Glass so cards keep a consistent tone across both. The dark
    /// value used to be a dark navy (#151A2E) at low alpha, which on the
    /// near-black background just looked like a slightly different dark
    /// blob instead of actual glass — real "frosted glass" on a dark
    /// background needs a *lighter* tint so it visibly catches light, so
    /// this is a lighter blue-gray at higher alpha instead.
    static let glassTint = Color(dynamic: UIColor(
        light: UIColor(hex: "#FFFFFF").withAlphaComponent(0.55),
        dark: UIColor(hex: "#3A4270").withAlphaComponent(0.55)
    ))

    static let glassBorder = Color(dynamic: UIColor(
        light: UIColor(hex: "#1A1B2E").withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.16)
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
    //
    // One controlled blue→indigo hue family, not four competing accent
    // colors — the earlier palette mixed blue/indigo/violet/cyan as equal
    // partners, which reads as a generic multicolor "AI" gradient. Every
    // brand surface here now ramps within a single hue instead.

    static let blue = Color(hex: "#2F5CFF")
    static let indigo = Color(hex: "#5A4FE0")
    static let indigoDeep = Color(hex: "#1B2160")
    static let violet = indigo // kept as an alias so existing call sites don't need touching

    static let success = Color(hex: "#2ED47A")
    static let danger = Color(hex: "#FF5C72")
    static let warning = Color(hex: "#FFB020")

    // MARK: Gradients

    static let brandGradient = LinearGradient(
        colors: [blue, indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The signature glossy card look. Kept to two bright, mid-tone stops
    /// on purpose — the earlier three-stop version ran all the way down to
    /// `indigoDeep`, which made the bottom-right corner look muddy and
    /// near-black in a real screenshot instead of the reference's evenly
    /// lit, vivid royal blue.
    static let balanceCardGradient = LinearGradient(
        colors: [Color(hex: "#5B7CFF"), Color(hex: "#4A3FC9")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroBackgroundGradient = RadialGradient(
        colors: [indigo.opacity(0.45), blue.opacity(0.16), .clear],
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
