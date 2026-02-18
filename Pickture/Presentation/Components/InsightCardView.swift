import SwiftUI

struct InsightCardView: View {
    let insight: StorageInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: insight.iconName)
                    .font(.title3)
                    .foregroundStyle(AppColors.ink)
                    .frame(width: 44, height: 44)
                    .background(iconBackgroundColor, in: Circle())
                    .overlay {
                        Circle().strokeBorder(AppColors.border, lineWidth: 2)
                    }

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(insight.title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.ink)
                    Text(insight.description)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.inkMuted)
                }

                Spacer()

                if insight.suggestedFilter != nil {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppColors.inkMuted)
                }
            }
            .padding(AppSpacing.sm)
            .brutalistCard()
        }
        .buttonStyle(.plain)
    }

    private var iconBackgroundColor: Color {
        switch insight.category {
        case .screenshots: AppColors.accentPurple.opacity(0.3)
        case .videos: AppColors.accentBlue.opacity(0.3)
        case .largeFiles: AppColors.accentRed.opacity(0.3)
        case .oldPhotos: AppColors.accentYellow.opacity(0.3)
        case .general: AppColors.background
        }
    }
}
