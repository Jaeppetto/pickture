import SwiftUI

extension View {
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    func surfaceStyle() -> some View {
        background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .cardShadow()
    }
}
