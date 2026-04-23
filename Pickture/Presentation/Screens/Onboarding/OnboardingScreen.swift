import SwiftUI

struct OnboardingScreen: View {
    let onCompleted: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showTrustSheet = false
    @State private var cardsVisible = false
    @State private var cardsSettled = false
    @State private var visibleHeadlineLineCount = 0
    @State private var ctaVisible = false

    private let pixelFont = Font.custom("PressStart2P-Regular", size: 18)

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                Text("Pickture.")
                    .font(pixelFont)
                    .foregroundStyle(AppColors.ink)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: AppSpacing.md)

                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    OnboardingCardIllustration(
                        cardsVisible: cardsVisible,
                        cardsSettled: cardsSettled
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            ForEach(Array(headlineLines.enumerated()), id: \.offset) { index, line in
                                Text(verbatim: line)
                                    .font(.system(size: 38, weight: .black))
                                    .foregroundStyle(AppColors.ink)
                                    .opacity(index < visibleHeadlineLineCount ? 1 : 0)
                                    .offset(y: headlineOffset(for: index))
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("Swipe. Clean. Lighten."))

                        Text("사진을 넘기듯 정리하고, 내 폰은 더 가볍게.")
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(ctaVisible ? 1 : 0)
                    }
                }

                Spacer(minLength: AppSpacing.md)

                Button {
                    HapticManager.buttonTap()
                    showTrustSheet = true
                } label: {
                    Text("Start Pickture")
                }
                .buttonStyle(.brutalistPrimary)
                .opacity(ctaVisible ? 1 : 0)
                .offset(y: reduceMotion || ctaVisible ? 0 : 10)
                .accessibilityHint(Text("온보딩 계속하기"))
            }
            .frame(maxWidth: 430, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.xl)
        }
        .onAppear(perform: runEntranceAnimation)
        .sheet(isPresented: $showTrustSheet) {
            OnboardingTrustSheet {
                HapticManager.buttonTap()
                showTrustSheet = false
                onCompleted()
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }

    private var headlineLines: [String] {
        let localized = String(localized: "Swipe. Clean. Lighten.")
        let newlineLines = localized
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if newlineLines.count > 1 {
            return newlineLines
        }

        return localized
            .split(separator: " ")
            .map(String.init)
    }

    private func headlineOffset(for index: Int) -> CGFloat {
        guard !reduceMotion, index >= visibleHeadlineLineCount else { return 0 }
        return 12
    }

    private func runEntranceAnimation() {
        guard !cardsVisible else { return }

        if reduceMotion {
            cardsVisible = true
            cardsSettled = true
            visibleHeadlineLineCount = headlineLines.count
            ctaVisible = true
            return
        }

        withAnimation(.spring(response: 0.52, dampingFraction: 0.72)) {
            cardsVisible = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.76)) {
                cardsSettled = true
            }

            for lineIndex in 1...headlineLines.count {
                try? await Task.sleep(for: .milliseconds(110))
                withAnimation(.easeOut(duration: 0.2)) {
                    visibleHeadlineLineCount = lineIndex
                }
            }

            try? await Task.sleep(for: .milliseconds(90))
            withAnimation(.easeOut(duration: 0.24)) {
                ctaVisible = true
            }
        }
    }
}

private struct OnboardingCardIllustration: View {
    let cardsVisible: Bool
    let cardsSettled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge, style: .continuous)
                        .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidthThick)
                }
                .background(
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge, style: .continuous)
                        .fill(AppColors.shadowColor)
                        .offset(x: AppSpacing.BrutalistTokens.shadowOffsetLarge, y: AppSpacing.BrutalistTokens.shadowOffsetLarge)
                )

            swipeCard(
                label: "삭제",
                icon: "trash.fill",
                color: AppColors.accentRed,
                rotation: cardsSettled ? -8 : -2,
                xOffset: cardsSettled ? -58 : -20,
                yOffset: cardsSettled ? -18 : 0
            )

            swipeCard(
                label: "보관",
                icon: "checkmark",
                color: AppColors.accentGreen,
                rotation: cardsSettled ? 8 : 2,
                xOffset: cardsSettled ? 58 : 20,
                yOffset: cardsSettled ? 20 : 0
            )

            RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small, style: .continuous)
                .fill(AppColors.accentYellow)
                .frame(width: 154, height: 18)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small, style: .continuous)
                        .strokeBorder(AppColors.border, lineWidth: 2)
                }
                .offset(y: 94)
                .opacity(cardsVisible ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.24, contentMode: .fit)
        .opacity(cardsVisible ? 1 : 0)
        .scaleEffect(cardsVisible ? 1 : 0.88)
        .accessibilityHidden(true)
    }

    private func swipeCard(
        label: LocalizedStringKey,
        icon: String,
        color: Color,
        rotation: Double,
        xOffset: CGFloat,
        yOffset: CGFloat
    ) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .black))
            Text(label)
                .font(AppTypography.bodySemibold)
        }
        .foregroundStyle(AppColors.ink)
        .frame(width: 132, height: 176)
        .background(color)
        .overlay {
            RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
        }
        .rotationEffect(.degrees(rotation))
        .offset(x: xOffset, y: yOffset)
    }
}

private struct OnboardingTrustSheet: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Capsule()
                .fill(AppColors.inkFaint)
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.xs)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                trustRow(
                    icon: "iphone.gen3",
                    text: "사진은 기기 안에서만 처리됩니다.",
                    color: AppColors.accentBlue
                )
                trustRow(
                    icon: "trash.square",
                    text: "삭제 전 대기열에서 한 번 더 확인합니다.",
                    color: AppColors.accentGreen
                )
            }

            Button {
                onContinue()
            } label: {
                Text("Continue")
            }
            .buttonStyle(.brutalistPrimary)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.background)
    }

    private func trustRow(icon: String, text: LocalizedStringKey, color: Color) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.ink)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.25), in: RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small)
                        .strokeBorder(AppColors.border, lineWidth: 1.5)
                }

            Text(text)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingScreen(onCompleted: {})
}
