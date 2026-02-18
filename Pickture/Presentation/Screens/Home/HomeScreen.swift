import SwiftUI

struct HomeScreen: View {
    @State var viewModel: HomeViewModel
    @State var permissionViewModel: PhotoPermissionViewModel
    var settingsViewModel: SettingsViewModel
    var deletionQueueViewModelFactory: () -> DeletionQueueViewModel

    @State private var showDeletionQueue = false

    var body: some View {
        NavigationStack {
            PhotoPermissionView(viewModel: permissionViewModel) {
                dashboardContent
            }
            .background(AppColors.background)
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    languageMenu
                }
            }
        }
        .task {
            await viewModel.loadTrashCount()
            if permissionViewModel.hasAnyAccess {
                await viewModel.loadStorageInfo()
            }
        }
        .onChange(of: permissionViewModel.authorizationStatus) { _, newValue in
            if newValue == .authorized || newValue == .limited {
                Task { await viewModel.loadStorageInfo() }
            }
        }
        .sheet(isPresented: $showDeletionQueue, onDismiss: {
            Task { await viewModel.loadTrashCount() }
        }) {
            DeletionQueueScreen(
                viewModel: deletionQueueViewModelFactory(),
                onDeletionCompleted: {}
            )
        }
    }

    // MARK: - Language Menu

    private var languageMenu: some View {
        Menu {
            Picker("언어", selection: Binding(
                get: { settingsViewModel.preferences.locale },
                set: { newValue in
                    Task { await settingsViewModel.updateLocale(newValue) }
                }
            )) {
                Text("시스템 언어").tag("system")
                Text("한국어").tag("ko")
                Text("English").tag("en")
                Text("日本語").tag("ja")
                Text("中文").tag("zh-Hans")
            }
        } label: {
            Image(systemName: "globe")
                .font(.body.weight(.medium))
                .foregroundStyle(AppColors.ink)
                .frame(width: 32, height: 32)
                .background(AppColors.surface, in: Circle())
                .overlay {
                    Circle().strokeBorder(AppColors.border, lineWidth: 1.5)
                }
        }
    }

    // MARK: - Dashboard

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                storageCard
                statsRow
                startCleaningButton
                trashQueueButton
            }
            .padding(AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .refreshable {
            await viewModel.loadStorageInfo()
        }
    }

    // MARK: - Storage Chart Card

    private var storageCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "externaldrive.fill.badge.checkmark")
                    .foregroundStyle(AppColors.ink)
                Text("스토리지 현황")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.ink)
            }

            if viewModel.isLoading && !viewModel.hasLoaded {
                storageSkeleton
            } else {
                StorageChartView(storageInfo: viewModel.storageInfo)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .brutalistCard()
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
                iconName: "photo",
                accentColor: AppColors.accentYellow
            )
            StatBadge(
                count: viewModel.storageInfo.totalVideoCount,
                label: "동영상",
                iconName: "video.fill",
                accentColor: AppColors.accentPurple
            )
            StatBadge(
                count: viewModel.storageInfo.totalScreenshotCount,
                label: "스크린샷",
                iconName: "camera.viewfinder",
                accentColor: AppColors.accentBlue
            )
        }
    }

    private var storageSkeleton: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            RoundedRectangle(cornerRadius: 4)
                .fill(AppColors.background)
                .frame(height: 20)
                .frame(maxWidth: 120)
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.background)
                .frame(height: 160)
        }
    }

    // MARK: - Start Cleaning CTA

    private var startCleaningButton: some View {
        Button {
            viewModel.startCleaning()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                Text("스와이프 정리 시작")
            }
            .brutalistPrimaryButton()
        }
    }

    // MARK: - Trash Queue Button

    @ViewBuilder
    private var trashQueueButton: some View {
        if viewModel.trashItemCount > 0 {
            Button {
                showDeletionQueue = true
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "trash")
                    Text("삭제 대기열 보기 (\(viewModel.trashItemCount))")
                        .foregroundStyle(AppColors.accentRed)
                }
                .brutalistSecondaryButton()
            }
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let count: Int
    let label: LocalizedStringKey
    let iconName: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(AppColors.ink)
                .frame(width: 30, height: 30)
                .background(accentColor.opacity(0.2), in: Circle())
                .overlay {
                    Circle().strokeBorder(AppColors.border, lineWidth: 1.5)
                }

            Text("\(count)")
                .font(AppTypography.monoBody)
                .foregroundStyle(AppColors.ink)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .brutalistCard(accent: accentColor)
    }
}
