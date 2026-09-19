import SwiftUI

struct CurrencySettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ForEach(FiatCurrency.allCases) { currency in
                    Button {
                        appState.settings.currency = currency
                        HapticManager.selectionChanged()
                    } label: {
                        HStack {
                            Text("\(currency.symbol) \(currency.rawValue)").foregroundStyle(Theme.textPrimary)
                            Spacer()
                            if appState.settings.currency == currency {
                                Image(systemName: "checkmark").foregroundStyle(Theme.success)
                            }
                        }
                        .padding(.vertical, Spacing.m)
                    }
                    if currency != FiatCurrency.allCases.last {
                        Divider().overlay(Theme.glassBorder)
                    }
                }
            }
            .padding(.horizontal, Spacing.m)
            .glassSurface()
            .padding(Spacing.l)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}
