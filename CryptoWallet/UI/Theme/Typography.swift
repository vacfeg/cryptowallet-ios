import SwiftUI

/// Rounded system font throughout — it's what reads as "premium fintech"
/// without shipping a custom font (and it supports Dynamic Type for free).
enum Typography {
    static let balanceDisplay = Font.system(size: 44, weight: .bold, design: .rounded)
    static let largeTitle = Font.system(size: 30, weight: .bold, design: .rounded)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let monoSmall = Font.system(.footnote, design: .monospaced)
    static let buttonLabel = Font.system(.body, design: .rounded).weight(.semibold)
}
