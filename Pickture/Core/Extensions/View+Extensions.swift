import SwiftUI

// MARK: - Brutalist View Modifiers

extension View {
    func brutalistCard(
        accent: Color = AppColors.shadowColor,
        shadowOffset: CGFloat = AppSpacing.BrutalistTokens.shadowOffset,
        borderWidth: CGFloat = AppSpacing.BrutalistTokens.borderWidth
    ) -> some View {
        modifier(BrutalistCardModifier(accent: accent, shadowOffset: shadowOffset, borderWidth: borderWidth))
    }

    func brutalistShadow(
        offset: CGFloat = AppSpacing.BrutalistTokens.shadowOffset,
        color: Color = AppColors.shadowColor
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .fill(color)
                    .offset(x: offset, y: offset)
            )
    }

    func brutalistBorder(width: CGFloat = AppSpacing.BrutalistTokens.borderWidth) -> some View {
        self
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .strokeBorder(AppColors.border, lineWidth: width)
            }
    }

    // MARK: - Legacy Compatibility

    func surfaceStyle() -> some View {
        brutalistCard()
    }

    func cardShadow() -> some View {
        brutalistShadow()
    }
}

// MARK: - Brutalist Card Modifier

private struct BrutalistCardModifier: ViewModifier {
    let accent: Color
    let shadowOffset: CGFloat
    let borderWidth: CGFloat

    private let cornerRadius = AppSpacing.BrutalistTokens.cornerRadius

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(shape.fill(AppColors.surface))
            .overlay {
                shape.strokeBorder(AppColors.border, lineWidth: borderWidth)
            }
            .background(
                shape
                    .fill(accent)
                    .offset(x: shadowOffset, y: shadowOffset)
            )
    }
}

// MARK: - Brutalist Button Style

struct BrutalistButtonPressMetrics {
    let bodyOffset: CGFloat
    let scale: CGFloat

    static func metrics(isPressed: Bool, shadowOffset: CGFloat) -> BrutalistButtonPressMetrics {
        guard isPressed else {
            return BrutalistButtonPressMetrics(
                bodyOffset: 0,
                scale: 1
            )
        }

        return BrutalistButtonPressMetrics(
            bodyOffset: shadowOffset * 0.9,
            scale: 0.995
        )
    }
}

struct BrutalistButtonStyle: ButtonStyle {
    enum Style {
        case primary, secondary, destructive, ghost
    }

    let style: Style

    private let shadowOffset = AppSpacing.BrutalistTokens.shadowOffset
    private let borderWidth = AppSpacing.BrutalistTokens.borderWidth
    private let cornerRadius = AppSpacing.BrutalistTokens.cornerRadius

    private var fillColor: Color {
        switch style {
        case .primary: AppColors.accentYellow
        case .secondary: AppColors.surface
        case .destructive: AppColors.accentRed
        case .ghost: .clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary: AppColors.ink
        case .secondary: AppColors.ink
        case .destructive: .white
        case .ghost: AppColors.ink
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: AppColors.shadowColor
        case .secondary: AppColors.shadowColor
        case .destructive: AppColors.shadowColor
        case .ghost: .clear
        }
    }

    private var hasShadow: Bool {
        style != .ghost
    }

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let metrics = BrutalistButtonPressMetrics.metrics(
            isPressed: configuration.isPressed,
            shadowOffset: shadowOffset
        )

        configuration.label
            .font(AppTypography.bodySemibold)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(shape.fill(fillColor))
            .overlay {
                shape.strokeBorder(AppColors.border, lineWidth: borderWidth)
            }
            .scaleEffect(metrics.scale)
            .offset(x: metrics.bodyOffset, y: metrics.bodyOffset)
            .background(alignment: .topLeading) {
                if hasShadow {
                    shape
                        .fill(shadowColor)
                        .offset(x: shadowOffset, y: shadowOffset)
                }
            }
            .padding(.trailing, hasShadow ? shadowOffset : 0)
            .padding(.bottom, hasShadow ? shadowOffset : 0)
            .contentShape(shape)
            .animation(.spring(response: 0.16, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BrutalistButtonStyle {
    static var brutalistPrimary: BrutalistButtonStyle { .init(style: .primary) }
    static var brutalistSecondary: BrutalistButtonStyle { .init(style: .secondary) }
    static var brutalistDestructive: BrutalistButtonStyle { .init(style: .destructive) }
    static var brutalistGhost: BrutalistButtonStyle { .init(style: .ghost) }
}
