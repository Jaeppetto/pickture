import SwiftUI

struct CleaningProgressView: View {
    let session: CleaningSession
    let totalPhotos: Int
    var onComplete: (() -> Void)?

    private var progress: Double {
        guard totalPhotos > 0 else { return 0 }
        return Double(session.totalReviewed) / Double(totalPhotos)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            // Top row: count + done button
            HStack {
                Text("\(session.totalReviewed)")
                    .font(AppTypography.monoTitle)
                    .foregroundStyle(AppColors.ink)
                +
                Text("/\(totalPhotos)")
                    .font(AppTypography.monoCaption)
                    .foregroundStyle(AppColors.inkMuted)

                Spacer()

                // Stat badges
                HStack(spacing: AppSpacing.sm) {
                    statBadge(count: session.totalDeleted, icon: "trash.fill", color: AppColors.delete)
                    statBadge(count: session.totalKept, icon: "checkmark", color: AppColors.keep)
                }

                if let onComplete {
                    Spacer()
                        .frame(width: AppSpacing.sm)

                    Button {
                        onComplete()
                    } label: {
                        Text("완료")
                            .font(AppTypography.bodySemibold)
                            .foregroundStyle(AppColors.ink)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xxs)
                            .background(AppColors.accentYellow)
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))
                            .overlay {
                                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small)
                                    .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
                            }
                    }
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small)
                        .fill(AppColors.surface)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small)
                                .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
                        }

                    RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small)
                        .fill(AppColors.accentYellow)
                        .frame(width: max(0, geometry.size.width * progress))
                        .animation(.easeInOut(duration: AppConstants.Animation.quickDuration), value: progress)
                }
            }
            .frame(height: 12)
        }
        .padding(AppSpacing.sm)
        .brutalistCard()
    }

    private func statBadge(count: Int, icon: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text("\(count)")
                .font(AppTypography.monoCaption)
        }
        .foregroundStyle(color)
    }
}
