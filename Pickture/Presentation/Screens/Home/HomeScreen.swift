import SwiftUI

struct HomeScreen: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    storageOverviewCard
                    quickActionCard
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("홈")
        }
        .task {
            await viewModel.loadStorageInfo()
        }
    }

    private var storageOverviewCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("스토리지 현황")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("사진 \(viewModel.storageInfo.totalPhotoCount)장")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("동영상 \(viewModel.storageInfo.totalVideoCount)개")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .surfaceStyle()
    }

    private var quickActionCard: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("갤러리 정리를 시작해보세요")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)

            NavigationLink {
                // Navigate to clean - will be connected in Phase 2
                EmptyView()
            } label: {
                Text("정리 시작")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            }
        }
        .padding(AppSpacing.md)
        .surfaceStyle()
    }
}
