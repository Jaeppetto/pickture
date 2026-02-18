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

    func brutalistPrimaryButton() -> some View {
        modifier(BrutalistButtonModifier(style: .primary))
    }

    func brutalistSecondaryButton() -> some View {
        modifier(BrutalistButtonModifier(style: .secondary))
    }

    func brutalistDestructiveButton() -> some View {
        modifier(BrutalistButtonModifier(style: .destructive))
    }

    func brutalistGhostButton() -> some View {
        modifier(BrutalistButtonModifier(style: .ghost))
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

    func glassPrimaryButton() -> some View {
        brutalistPrimaryButton()
    }

    func glassDestructiveButton() -> some View {
        brutalistDestructiveButton()
    }

    func subtleButton(tint: Color = AppColors.primary) -> some View {
        brutalistSecondaryButton()
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

// MARK: - Brutalist Button Modifier

private struct BrutalistButtonModifier: ViewModifier {
    enum Style {
        case primary, secondary, destructive, ghost
    }

    let style: Style

    @State private var isPressed = false

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

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let currentOffset = isPressed ? shadowOffset : 0

        content
            .font(AppTypography.bodySemibold)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(shape.fill(fillColor))
            .overlay {
                shape.strokeBorder(AppColors.border, lineWidth: borderWidth)
            }
            .background(
                hasShadow
                    ? AnyView(
                        shape
                            .fill(shadowColor)
                            .offset(x: shadowOffset, y: shadowOffset)
                    )
                    : AnyView(EmptyView())
            )
            .offset(x: currentOffset, y: currentOffset)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
