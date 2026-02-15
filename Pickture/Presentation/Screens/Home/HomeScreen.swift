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
            .navigationBarTitleDisplayMode(.large)
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
            VStack(spacing: AppSpacing.md) {
                quickActionCard
                storageCard
                statsRow
                insightsSection
            }
            .padding(AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .refreshable {
            await viewModel.loadStorageInfo()
        }
    }

    private var quickActionCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("오늘의 정리")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("추천")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxxs)
                    .background(AppColors.background, in: Capsule())
            }

            Text("최근 사진부터 빠르게 넘기며 보관/삭제를 진행하세요.")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)

            startCleaningButton
        }
        .padding(AppSpacing.md)
        .surfaceStyle()
    }

    // MARK: - Storage Chart Card

    private var storageCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "externaldrive.fill.badge.checkmark")
                    .foregroundStyle(AppColors.primary)
                Text("스토리지 현황")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)
            }

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
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: AppSpacing.sm
        ) {
            StatBadge(
                count: viewModel.storageInfo.totalPhotoCount,
                label: "사진",
                iconName: "photo"
            )
            StatBadge(
                count: viewModel.storageInfo.totalVideoCount,
                label: "동영상",
                iconName: "video.fill"
            )
            StatBadge(
                count: viewModel.storageInfo.totalScreenshotCount,
                label: "스크린샷",
                iconName: "camera.viewfinder"
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
            .glassPrimaryButton()
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let count: Int
    let label: String
    let iconName: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 30, height: 30)
                .background(AppColors.background, in: Circle())

            Text("\(count)")
                .font(AppTypography.monoBody)
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .surfaceStyle()
    }
}
