import SwiftUI

/// Default (non-rounded) SF Pro throughout — matches the crisp, tight
/// sans-serif in the reference design. `design: .rounded` was tried
/// earlier and dropped: its soft, bubbly letterforms read as "childish"
/// next to the reference's sharp numerals, especially at the balance
/// display's large bold size.
enum Typography {
    static let balanceDisplay = Font.system(size: 46, weight: .bold, design: .default)
    static let largeTitle = Font.system(size: 30, weight: .bold, design: .default)
    static let title = Font.system(.title2, design: .default).weight(.bold)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let subheadline = Font.system(.subheadline, design: .default)
    static let caption = Font.system(.caption, design: .default)
    static let monoSmall = Font.system(.footnote, design: .monospaced)
    static let buttonLabel = Font.system(.body, design: .default).weight(.semibold)
}
