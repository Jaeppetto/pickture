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
                expirationWarningBanner
                statsRow
                lastSessionCard
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

    // MARK: - Expiration Warning Banner

    @ViewBuilder
    private var expirationWarningBanner: some View {
        if viewModel.expiringItemCount > 0 {
            Button {
                showDeletionQueue = true
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppColors.accentRed)
                        .frame(width: 36, height: 36)
                        .background(AppColors.accentRed.opacity(0.15), in: Circle())
                        .overlay {
                            Circle().strokeBorder(AppColors.accentRed, lineWidth: 1.5)
                        }

                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        Text("\(String(viewModel.expiringItemCount))개 항목이 곧 만료됩니다")
                            .font(AppTypography.bodySemibold)
                            .foregroundStyle(AppColors.ink)

                        Text("총 \(formattedBytes(viewModel.expiringItemsTotalBytes)) · 삭제 전 확인")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.inkMuted)
                    }

                    Spacer()

                    Text("지금 확인")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.accentRed)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.accentRed)
                }
                .padding(AppSpacing.md)
                .brutalistCard(accent: AppColors.accentRed)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Last Session Summary Card

    @ViewBuilder
    private var lastSessionCard: some View {
        if let session = viewModel.lastSession {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("마지막 정리")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.ink)

                Rectangle()
                    .fill(AppColors.ink)
                    .frame(height: 2)

                HStack(spacing: AppSpacing.lg) {
                    HStack(spacing: AppSpacing.xxs) {
                        Circle()
                            .fill(AppColors.ink)
                            .frame(width: 6, height: 6)
                        Text("\(String(session.totalReviewed))장 검토")
                            .font(AppTypography.monoCaption)
                            .foregroundStyle(AppColors.ink)
                    }
                    HStack(spacing: AppSpacing.xxs) {
                        Circle()
                            .fill(AppColors.accentRed)
                            .frame(width: 6, height: 6)
                        Text("\(String(session.totalDeleted))장 삭제")
                            .font(AppTypography.monoCaption)
                            .foregroundStyle(AppColors.ink)
                    }
                    HStack(spacing: AppSpacing.xxs) {
                        Circle()
                            .fill(AppColors.accentGreen)
                            .frame(width: 6, height: 6)
                        Text("\(String(session.totalKept))장 보관")
                            .font(AppTypography.monoCaption)
                            .foregroundStyle(AppColors.ink)
                    }
                }

                HStack(spacing: AppSpacing.xs) {
                    Text("\(formattedBytes(session.freedBytes)) 확보")
                        .font(AppTypography.monoCaption)
                        .foregroundStyle(AppColors.inkMuted)
                    Text("·")
                        .foregroundStyle(AppColors.inkMuted)
                    Text(session.endedAt ?? session.startedAt, style: .relative)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.inkMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .brutalistCard()
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

// MARK: - Formatted Bytes Helper

private func formattedBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
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
