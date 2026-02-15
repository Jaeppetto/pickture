import SwiftUI

extension View {
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
    }

    func surfaceStyle() -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
        return self
            .background(shape.fill(AppColors.surface))
            .overlay {
                shape.strokeBorder(AppColors.cardBorder, lineWidth: 1)
            }
            .cardShadow()
    }

    // MARK: - Buttons

    func glassPrimaryButton() -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
        return self
            .font(AppTypography.bodySemibold)
            .foregroundStyle(Color(uiColor: .systemBackground))
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background {
                shape.fill(AppColors.chrome)
            }
            .overlay {
                shape.strokeBorder(.white.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    func glassDestructiveButton() -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
        return self
            .font(AppTypography.bodySemibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background {
                shape.fill(AppColors.delete)
            }
            .overlay {
                shape.strokeBorder(.white.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: AppColors.delete.opacity(0.28), radius: 10, x: 0, y: 4)
    }

    func subtleButton(tint: Color = AppColors.primary) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
        return self
            .font(AppTypography.bodySemibold)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background {
                shape.fill(AppColors.surface)
            }
            .overlay {
                shape.strokeBorder(AppColors.cardBorder, lineWidth: 1)
            }
    }

    // MARK: - Shimmer

    func shimmer(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if active {
            content
                .overlay {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.3),
                                .clear,
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: width * 0.6)
                        .offset(x: -width * 0.3 + phase * (width * 1.6))
                    }
                    .clipped()
                }
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}
