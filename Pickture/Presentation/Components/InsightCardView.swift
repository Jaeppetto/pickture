import SwiftUI

struct InsightCardView: View {
    let insight: StorageInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: insight.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background(iconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(insight.title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(insight.description)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                if insight.suggestedFilter != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.sm)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .cardShadow()
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch insight.category {
        case .screenshots: Color(hex: 0xFF9500)
        case .videos: Color(hex: 0x7C3AED)
        case .largeFiles: Color(hex: 0xFF3B30)
        case .oldPhotos: AppColors.textSecondary
        case .general: AppColors.primary
        }
    }
}
