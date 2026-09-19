import SwiftUI

struct AssetsSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var contractAddress = ""
    @State private var symbol = ""
    @State private var name = ""
    @State private var decimals = "18"
    @State private var errorMessage: String?
    @State private var customTokens: [Token] = []

    private let store = CustomTokenStore()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.l) {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("Add Custom Token")
                            .font(Typography.headline)
                            .foregroundStyle(Theme.textPrimary)
                        field("Contract Address", text: $contractAddress)
                        HStack(spacing: Spacing.s) {
                            field("Symbol", text: $symbol)
                            field("Decimals", text: $decimals, keyboard: .numberPad)
                        }
                        field("Name", text: $name)

                        if let errorMessage {
                            Text(errorMessage).font(Typography.caption).foregroundStyle(Theme.danger)
                        }

                        PrimaryButton(title: "Add Token", isDisabled: !canAdd) { addToken() }
                    }
                    .padding(Spacing.l)
                    .glassSurface()

                    if !customTokens.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Your Custom Tokens")
                                .font(Typography.headline)
                                .foregroundStyle(Theme.textPrimary)
                            VStack(spacing: 0) {
                                ForEach(customTokens) { token in
                                    HStack {
                                        Text(token.symbol).foregroundStyle(Theme.textPrimary)
                                        Text(token.contractAddress?.truncatedAddress ?? "").font(Typography.caption).foregroundStyle(Theme.textTertiary)
                                        Spacer()
                                        Button {
                                            store.remove(token)
                                            refresh()
                                        } label: {
                                            Image(systemName: "trash").foregroundStyle(Theme.danger)
                                        }
                                    }
                                    .padding(.vertical, Spacing.s)
                                    if token.id != customTokens.last?.id {
                                        Divider().overlay(Theme.glassBorder)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.m)
                            .glassSurface()
                        }
                    }
                }
                .padding(Spacing.l)
            }
        }
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: refresh)
    }

    private var canAdd: Bool {
        BlockchainProviderFactory.provider(for: appState.selectedNetwork).isValid(address: contractAddress)
            && !symbol.isEmpty && Int(decimals) != nil
    }

    private func addToken() {
        guard let decimalsValue = Int(decimals) else { return }
        let token = Token(
            networkID: appState.selectedNetwork.id,
            contractAddress: contractAddress,
            symbol: symbol.uppercased(),
            name: name.isEmpty ? symbol.uppercased() : name,
            decimals: decimalsValue,
            iconSystemName: "circlebadge.fill",
            coinGeckoID: nil
        )
        store.add(token)
        contractAddress = ""; symbol = ""; name = ""; decimals = "18"
        errorMessage = nil
        HapticManager.success()
        refresh()
    }

    private func refresh() {
        customTokens = store.tokens(for: appState.selectedNetwork.id)
    }

    private func field(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .foregroundStyle(Theme.textPrimary)
            .padding(Spacing.m)
            .glassSurface(cornerRadius: Radius.small)
    }
}
