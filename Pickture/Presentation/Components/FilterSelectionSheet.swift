import SwiftUI

struct FilterSelectionSheet: View {
    let onFilterSelected: (CleaningFilter?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("정리할 사진을 선택하세요")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, AppSpacing.md)

                VStack(spacing: AppSpacing.sm) {
                    filterButton(
                        title: "전체 사진",
                        subtitle: "모든 사진을 순서대로 정리",
                        icon: "photo.on.rectangle",
                        color: AppColors.primary
                    ) {
                        select(filter: nil)
                    }

                    filterButton(
                        title: "스크린샷",
                        subtitle: "스크린샷만 빠르게 정리",
                        icon: "camera.viewfinder",
                        color: Color(hex: 0xFF9500)
                    ) {
                        select(filter: .screenshotsOnly())
                    }

                    filterButton(
                        title: "동영상",
                        subtitle: "용량 큰 동영상 정리",
                        icon: "video.fill",
                        color: Color(hex: 0x7C3AED)
                    ) {
                        select(filter: .videosOnly())
                    }

                    filterButton(
                        title: "용량 큰 파일",
                        subtitle: "10MB 이상 파일만 정리",
                        icon: "doc.fill",
                        color: Color(hex: 0xFF3B30)
                    ) {
                        select(filter: .largeFiles())
                    }
                }
                .padding(.horizontal, AppSpacing.md)

                Spacer()
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func filterButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .cardShadow()
        }
        .buttonStyle(.plain)
    }

    private func select(filter: CleaningFilter?) {
        dismiss()
        onFilterSelected(filter)
    }
}
