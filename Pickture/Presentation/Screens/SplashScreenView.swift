import SwiftUI

struct SplashScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hasAppeared = false
    @State private var dotCount = 0

    private let titleFont = Font.custom("PressStart2P-Regular", size: 22)
    private let dotTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            background

            VStack(spacing: AppSpacing.xxl) {
                mark

                titleBlock
            }
            .padding(.horizontal, AppSpacing.xxl)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Pickture")
        }
        .onReceive(dotTimer) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                dotCount = (dotCount % 3) + 1
            }
        }
        .onAppear {
            if reduceMotion {
                hasAppeared = true
            } else {
                withAnimation(.spring(response: 0.72, dampingFraction: 0.78)) {
                    hasAppeared = true
                }
            }
        }
    }

    private var background: some View {
        ZStack {
            AppColors.background

            VStack(spacing: AppSpacing.sm) {
                ForEach(0..<16, id: \.self) { _ in
                    Rectangle()
                        .fill(AppColors.ink.opacity(0.035))
                        .frame(height: 2)
                }
            }
            .rotationEffect(.degrees(-8))
            .scaleEffect(1.3)
            .opacity(hasAppeared ? 1 : 0)
        }
        .ignoresSafeArea()
    }

    private var mark: some View {
        ZStack {
            card(
                color: AppColors.accentBlue,
                symbol: "photo.on.rectangle",
                rotation: hasAppeared ? -12 : -2,
                offset: CGSize(width: hasAppeared ? -34 : 0, height: hasAppeared ? 16 : 0),
                delay: 0
            )

            card(
                color: AppColors.accentYellow,
                symbol: "sparkles",
                rotation: hasAppeared ? 9 : 2,
                offset: CGSize(width: hasAppeared ? 30 : 0, height: hasAppeared ? 6 : 0),
                delay: 0.08
            )

            iconTile
                .scaleEffect(hasAppeared ? 1 : 0.76)
                .opacity(hasAppeared ? 1 : 0)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.72).delay(0.14),
                    value: hasAppeared
                )
        }
        .frame(width: 196, height: 178)
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                .fill(AppColors.ink)
                .frame(width: 126, height: 126)
                .offset(
                    x: hasAppeared ? AppSpacing.BrutalistTokens.shadowOffsetLarge : 0,
                    y: hasAppeared ? AppSpacing.BrutalistTokens.shadowOffsetLarge : 0
                )

            RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                .fill(AppColors.surface)
                .frame(width: 126, height: 126)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge)
                        .stroke(AppColors.ink, lineWidth: AppSpacing.BrutalistTokens.borderWidthThick)
                }

            Image("SplashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .accessibilityHidden(true)
        }
    }

    private func card(
        color: Color,
        symbol: String,
        rotation: Double,
        offset: CGSize,
        delay: Double
    ) -> some View {
        RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.extraLarge)
            .fill(color)
            .frame(width: 104, height: 128)
            .overlay(alignment: .topLeading) {
                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppColors.ink)
                    .padding(AppSpacing.md)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.extraLarge)
                    .stroke(AppColors.ink, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
            }
            .rotationEffect(.degrees(rotation))
            .offset(offset)
            .scaleEffect(hasAppeared ? 1 : 0.82)
            .opacity(hasAppeared ? 1 : 0)
            .animation(
                reduceMotion ? nil : .spring(response: 0.62, dampingFraction: 0.76).delay(delay),
                value: hasAppeared
            )
            .accessibilityHidden(true)
    }

    private var titleBlock: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Pickture.")
                .font(titleFont)
                .foregroundStyle(AppColors.ink)
                .tracking(2)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("clean your camera roll")
                .font(AppTypography.monoCaption)
                .foregroundStyle(AppColors.inkMuted)
                .textCase(.uppercase)
                .tracking(1.4)
                .multilineTextAlignment(.center)

            loadingDots
        }
        .offset(y: hasAppeared && !reduceMotion ? 0 : 18)
        .opacity(hasAppeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.38).delay(0.32), value: hasAppeared)
    }

    private var loadingDots: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall)
                    .fill(index < dotCount ? AppColors.ink : AppColors.inkFaint)
                    .frame(width: 18, height: 8)
            }
        }
        .padding(.top, AppSpacing.xs)
        .accessibilityHidden(true)
    }
}

#Preview {
    SplashScreenView()
}
