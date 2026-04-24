import SwiftUI

struct OnboardingScreen: View {
    let onCompleted: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                    onCompleted()
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
        GeometryReader { proxy in
            let shadowOffset = AppSpacing.BrutalistTokens.shadowOffsetLarge
            let contentSize = CGSize(
                width: max(0, proxy.size.width - shadowOffset),
                height: max(0, proxy.size.height - shadowOffset)
            )
            let shape = RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusLarge, style: .continuous)

            ZStack(alignment: .topLeading) {
                shape
                    .fill(AppColors.shadowColor)
                    .frame(width: contentSize.width, height: contentSize.height)
                    .offset(x: shadowOffset, y: shadowOffset)

                ZStack {
                    shape
                        .fill(AppColors.surface)

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
                .frame(width: contentSize.width, height: contentSize.height)
                .compositingGroup()
                .clipShape(shape)
                .overlay {
                    shape
                        .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidthThick)
                }
            }
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
        let shape = RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)

        return VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .black))
            Text(label)
                .font(AppTypography.bodySemibold)
        }
        .foregroundStyle(AppColors.ink)
        .frame(width: 132, height: 176)
        .background(shape.fill(color))
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
        }
        .rotationEffect(.degrees(rotation))
        .offset(x: xOffset, y: yOffset)
    }
}

#Preview {
    OnboardingScreen(onCompleted: {})
}
