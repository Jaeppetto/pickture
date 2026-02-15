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
}
