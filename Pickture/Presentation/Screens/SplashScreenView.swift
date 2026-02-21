import SwiftUI

struct SplashScreenView: View {
    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var dotCount = 0
    @State private var borderVisible = false

    private let pixelFont = Font.custom("PressStart2P-Regular", size: 22)
    private let dotTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                // App Icon with brutalist border
                ZStack {
                    // Shadow layer
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                        .fill(AppColors.ink)
                        .frame(width: 120, height: 120)
                        .offset(
                            x: borderVisible ? AppSpacing.BrutalistTokens.shadowOffset : 0,
                            y: borderVisible ? AppSpacing.BrutalistTokens.shadowOffset : 0
                        )

                    // Main container
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                        .fill(AppColors.surface)
                        .frame(width: 120, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                                .stroke(AppColors.ink, lineWidth: AppSpacing.BrutalistTokens.borderWidthThick)
                        )

                    // Icon
                    Image("SplashIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                // Title
                VStack(spacing: AppSpacing.xs) {
                    Text("Pickture.")
                        .font(pixelFont)
                        .foregroundStyle(AppColors.ink)
                        .tracking(2)

                    // Loading dots
                    HStack(spacing: AppSpacing.xxs) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index < dotCount ? AppColors.ink : AppColors.inkFaint)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, AppSpacing.xs)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
            }
        }
        .onReceive(dotTimer) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                dotCount = (dotCount % 3) + 1
            }
        }
        .onAppear {
            // Icon entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }

            // Border shadow pop
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                borderVisible = true
            }

            // Title slide up
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
    }
}
