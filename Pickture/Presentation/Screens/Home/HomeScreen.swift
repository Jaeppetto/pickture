import SwiftUI

struct HomeScreen: View {
    @State var viewModel: HomeViewModel
    @State var permissionViewModel: PhotoPermissionViewModel

    var body: some View {
        NavigationStack {
            PhotoPermissionView(viewModel: permissionViewModel) {
                dashboardContent
            }
            .background(AppColors.background)
            .navigationTitle("홈")
        }
        .task {
            if permissionViewModel.hasAnyAccess {
                await viewModel.loadStorageInfo()
            }
        }
        .onChange(of: permissionViewModel.authorizationStatus) { _, newValue in
            if newValue == .authorized || newValue == .limited {
                Task { await viewModel.loadStorageInfo() }
            }
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                storageCard
                statsRow
                insightsSection
                startCleaningButton
            }
            .padding(AppSpacing.md)
        }
        .refreshable {
            await viewModel.loadStorageInfo()
        }
    }

    // MARK: - Storage Chart Card

    private var storageCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("스토리지 현황")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.isLoading && !viewModel.hasLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                StorageChartView(storageInfo: viewModel.storageInfo)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .surfaceStyle()
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            StatBadge(
                count: viewModel.storageInfo.totalPhotoCount,
                label: "사진",
                iconName: "photo",
                color: AppColors.primary
            )
            StatBadge(
                count: viewModel.storageInfo.totalVideoCount,
                label: "동영상",
                iconName: "video.fill",
                color: Color(hex: 0x7C3AED)
            )
            StatBadge(
                count: viewModel.storageInfo.totalScreenshotCount,
                label: "스크린샷",
                iconName: "camera.viewfinder",
                color: Color(hex: 0xFF9500)
            )
        }
    }

    // MARK: - Insights Section

    @ViewBuilder
    private var insightsSection: some View {
        if !viewModel.insights.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("인사이트")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)

                ForEach(viewModel.insights) { insight in
                    InsightCardView(insight: insight) {
                        viewModel.startCleaning(with: insight.suggestedFilter)
                    }
                }
            }
        }
    }

    // MARK: - Start Cleaning CTA

    private var startCleaningButton: some View {
        Button {
            viewModel.startCleaning()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                Text("정리 시작")
            }
            .font(AppTypography.bodySemibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let count: Int
    let label: String
    let iconName: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text("\(count)")
                .font(AppTypography.monoBody)
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
        .cardShadow()
    }
}
