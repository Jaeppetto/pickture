import SwiftUI

extension View {
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    func surfaceStyle() -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium)
        return self
            .background(.thinMaterial, in: shape)
            .overlay {
                shape.strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            }
            .cardShadow()
    }

    // MARK: - Glassmorphism Buttons

    func glassPrimaryButton() -> some View {
        self
            .font(AppTypography.bodySemibold)
            .foregroundStyle(AppColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .glassBackground(tint: AppColors.primary)
    }

    func glassDestructiveButton() -> some View {
        self
            .font(AppTypography.bodySemibold)
            .foregroundStyle(AppColors.delete)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .glassBackground(tint: AppColors.delete)
    }

    private func glassBackground(tint: Color) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large)
        return self
            .background {
                shape.fill(.ultraThinMaterial)
                    .overlay {
                        shape.fill(tint.opacity(0.12))
                    }
            }
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [tint.opacity(0.3), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
    }
}
