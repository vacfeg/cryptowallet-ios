import SwiftUI

struct QRScannerView: View {
    let onScanned: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var permissionDenied = false
    @State private var isChecking = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isChecking {
                ProgressView().tint(.white)
            } else if permissionDenied {
                deniedState
            } else {
                ScannerRepresentable { code in
                    guard let address = CryptoURIParser.extractAddress(from: code) else { return }
                    HapticManager.success()
                    onScanned(address)
                    dismiss()
                }
                .ignoresSafeArea()

                scannerOverlay
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(Spacing.l)
                }
                Spacer()
            }
        }
        .task {
            let granted = await QRScannerPermission.request()
            permissionDenied = !granted
            isChecking = false
        }
    }

    private var scannerOverlay: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            RoundedRectangle(cornerRadius: Radius.large, style: .continuous)
                .strokeBorder(.white.opacity(0.8), lineWidth: 2)
                .frame(width: 260, height: 260)
            Text("Align the QR code within the frame")
                .font(Typography.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
    }

    private var deniedState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "camera.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.7))
            Text("Camera access needed")
                .font(Typography.headline)
                .foregroundStyle(.white)
            Text("Enable camera access in Settings to scan QR codes.")
                .font(Typography.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            SecondaryButton(title: "Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
    }
}

private struct ScannerRepresentable: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.onCode = onCode
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {}
}
