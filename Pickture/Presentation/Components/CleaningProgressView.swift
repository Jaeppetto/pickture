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
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColors.surface)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(AppColors.border, lineWidth: 2)
                        }
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColors.accentYellow)
                        .frame(width: max(0, geometry.size.width * progress), height: 10)
                        .animation(.easeInOut(duration: AppConstants.Animation.quickDuration), value: progress)
                }
            }
            .frame(height: 10)

            // Stats row
            HStack(spacing: AppSpacing.md) {
                Text("\(session.totalReviewed)/\(totalPhotos)")
                    .font(AppTypography.monoCaption)
                    .foregroundStyle(AppColors.inkMuted)

                Spacer()

                HStack(spacing: AppSpacing.sm) {
                    statBadge(count: session.totalDeleted, icon: "trash.fill", color: AppColors.delete)
                    statBadge(count: session.totalKept, icon: "checkmark", color: AppColors.keep)
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
