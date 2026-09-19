import SwiftUI

struct OnboardingView: View {
    // Plain Bool-driven `NavigationLink(isActive:)` rather than the newer
    // `NavigationStack(path:)` + `.navigationDestination(for:)` — that pair
    // requires iOS 16, and this screen must run on iOS 15. The classic
    // link/isActive pattern is deprecated on newer iOS but still fully
    // functional, which is the right trade for a two-destination flow like
    // this one.
    @State private var showCreate = false
    @State private var showImport = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 24

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                AnimatedBackground().ignoresSafeArea()

                NavigationLink(destination: CreateWalletFlowView(), isActive: $showCreate) { EmptyView() }
                    .hidden()
                NavigationLink(destination: ImportWalletView(), isActive: $showImport) { EmptyView() }
                    .hidden()

                VStack {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Theme.brandGradient)
                            .frame(width: 80, height: 80)
                            .blur(radius: 14)
                            .opacity(0.55)
                        Circle()
                            .fill(Theme.brandGradient)
                            .frame(width: 72, height: 72)
                        Image(systemName: "hexagon.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: Spacing.s) {
                        Text("Your crypto,")
                        Text("your control.")
                    }
                    .font(Typography.largeTitle)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.l)

                    Text("A non-custodial wallet. Your keys never leave this device.")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.xs)
                        .padding(.horizontal, Spacing.xl)

                    Spacer()

                    VStack(spacing: Spacing.m) {
                        PrimaryButton(title: "Create Wallet", icon: "plus.circle.fill") {
                            showCreate = true
                        }
                        SecondaryButton(title: "Import Wallet", icon: "arrow.down.circle") {
                            showImport = true
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.xl)
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }
}
