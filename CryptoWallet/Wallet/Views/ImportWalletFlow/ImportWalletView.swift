import SwiftUI

struct ImportWalletView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phrase = ""
    @State private var errorMessage: String?
    @State private var isImporting = false
    @FocusState private var isFocused: Bool

    private var wordCount: Int { MnemonicService.words(in: phrase).count }
    private var isValidLength: Bool { [12, 15, 18, 21, 24].contains(wordCount) }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.l) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Enter your recovery phrase")
                        .font(Typography.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Separate each word with a space. Your phrase is validated on this device and never sent anywhere.")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                textEditor
                    .frame(minHeight: 140)
                    .padding(Spacing.s)
                    .glassSurface(cornerRadius: Radius.medium)

                HStack {
                    Text("\(wordCount) words")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textTertiary)
                    Spacer()
                    if let errorMessage {
                        Text(errorMessage)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.danger)
                    }
                }

                Spacer()

                PrimaryButton(title: "Import Wallet", isLoading: isImporting, isDisabled: !isValidLength) {
                    importWallet()
                }
            }
            .padding(Spacing.l)
        }
        .onAppear { appState.isOnboardingFlowActive = true }
        .onDisappear { appState.isOnboardingFlowActive = false }
        .navigationBarHidden(true)
    }

    /// `.scrollContentBackground(.hidden)` (needed to see the glass card
    /// through `TextEditor`'s own background) is iOS 16+ only. On iOS 15
    /// the editor keeps its default system background — a minor visual
    /// compromise on the oldest supported OS rather than a broken build.
    @ViewBuilder
    private var textEditor: some View {
        let base = TextEditor(text: $phrase)
            .focused($isFocused)
            .font(Typography.body)
            .foregroundStyle(Theme.textPrimary)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .privacySensitive(true)

        if #available(iOS 16.0, *) {
            base.scrollContentBackground(.hidden)
        } else {
            base
        }
    }

    private func importWallet() {
        isFocused = false
        isImporting = true
        errorMessage = nil

        // BIP-39 checksum validation happens inside WalletManager — this is
        // a real cryptographic check, not just a word-count sanity check.
        Task { @MainActor in
            do {
                _ = try appState.walletManager.importWallet(mnemonic: phrase)
                HapticManager.success()
                appState.isOnboardingFlowActive = false
            } catch {
                isImporting = false
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Import failed."
                HapticManager.error()
            }
        }
    }
}
