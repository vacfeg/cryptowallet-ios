import SwiftUI
import CoreImage

struct ReceiveView: View {
    let network: Network

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    private var account: WalletAccount? {
        appState.walletManager.account(kind: network.kind)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: Spacing.l) {
                    Spacer()

                    if let account {
                        VStack(spacing: Spacing.s) {
                            Text(network.symbol)
                                .font(Typography.headline)
                                .foregroundStyle(Theme.textPrimary)
                            HStack(spacing: 6) {
                                Image(systemName: network.iconSystemName).font(.system(size: 12))
                                Text(network.name)
                            }
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, 6)
                            .glassSurface(cornerRadius: Radius.pill)
                        }

                        QRCodeView(content: account.address)
                            .frame(width: 220, height: 220)
                            .padding(Spacing.l)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium, style: .continuous))
                            .cardShadow()

                        VStack(spacing: Spacing.xs) {
                            Text(account.address)
                                .font(Typography.monoSmall)
                                .foregroundStyle(Theme.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.l)
                            Text("Only send \(network.symbol) and \(network.name) assets to this address.")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }

                        Spacer()

                        HStack(spacing: Spacing.m) {
                            SecondaryButton(title: "Copy", icon: "doc.on.doc") {
                                UIPasteboard.general.string = account.address
                                HapticManager.success()
                            }
                            SecondaryButton(title: "Share", icon: "square.and.arrow.up") {
                                showShareSheet = true
                            }
                        }
                        .padding(.horizontal, Spacing.l)
                        .padding(.bottom, Spacing.xl)
                    } else {
                        EmptyStateView(icon: "exclamationmark.triangle", title: "No address", message: "This account hasn't been set up yet.")
                        Spacer()
                    }
                }
            }
            .navigationTitle("Receive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(Theme.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let account {
                ShareSheet(items: [account.address])
            }
        }
    }
}

/// Native QR generation via CoreImage — no third-party dependency needed.
struct QRCodeView: View {
    let content: String

    var body: some View {
        if let image = QRCodeView.generate(from: content) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Color.gray.opacity(0.2)
        }
    }

    static func generate(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaled = outputImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
