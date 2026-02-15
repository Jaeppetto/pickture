import SwiftUI

struct InsightCardView: View {
    let insight: StorageInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: insight.iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background(AppColors.background, in: RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))

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
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.sm)
            .surfaceStyle()
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch insight.category {
        case .screenshots: AppColors.textSecondary
        case .videos: AppColors.textSecondary
        case .largeFiles: AppColors.delete
        case .oldPhotos: AppColors.textSecondary
        case .general: AppColors.textPrimary
        }
    }
}
