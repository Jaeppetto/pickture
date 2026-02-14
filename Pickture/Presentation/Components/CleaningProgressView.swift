import SwiftUI

struct CleaningProgressView: View {
    let session: CleaningSession
    let totalPhotos: Int

    private var progress: Double {
        guard totalPhotos > 0 else { return 0 }
        return Double(session.totalReviewed) / Double(totalPhotos)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.surface)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.primaryGradient)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.easeInOut(duration: AppConstants.Animation.quickDuration), value: progress)
                }
            }
            .frame(height: 6)

            // Stats row
            HStack(spacing: AppSpacing.md) {
                Text("\(session.totalReviewed)/\(totalPhotos)")
                    .font(AppTypography.monoCaption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                HStack(spacing: AppSpacing.sm) {
                    statBadge(count: session.totalDeleted, icon: "trash.fill", color: AppColors.delete)
                    statBadge(count: session.totalKept, icon: "checkmark", color: AppColors.keep)
                    statBadge(count: session.totalFavorited, icon: "star.fill", color: AppColors.favorite)
                }
            }
        }
    }

    private func statBadge(count: Int, icon: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(count)")
                .font(AppTypography.monoCaption)
        }
        .foregroundStyle(color)
    }
}
