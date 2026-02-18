import SwiftUI

struct CleanScreen: View {
    @State var viewModel: CleanViewModel
    @State var permissionViewModel: PhotoPermissionViewModel
    var navigationCoordinator: NavigationCoordinator
    var deletionQueueViewModelFactory: () -> DeletionQueueViewModel
    var photoRepository: any PhotoRepositoryProtocol

    @State private var showDeletionQueue = false
    @State private var showStartPicker = false

    var body: some View {
        NavigationStack {
            PhotoPermissionView(viewModel: permissionViewModel) {
                cleanContent
            }
            .background(AppColors.background)
            .navigationTitle("정리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .cleaning = viewModel.screenState {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("완료") {
                            Task { await viewModel.completeSession() }
                        }
                        .font(AppTypography.bodyMedium)
                    }
                }
            }
        }
        .task {
            await viewModel.checkForActiveSession()
        }
        .onChange(of: navigationCoordinator.selectedTab) { _, newTab in
            if newTab == .clean, let filter = navigationCoordinator.consumePendingFilter() {
                Task { await viewModel.applyPendingFilter(filter) }
            }
        }
        .sheet(isPresented: $showDeletionQueue) {
            DeletionQueueScreen(
                viewModel: deletionQueueViewModelFactory(),
                onDeletionCompleted: {
                    viewModel.returnToIdle()
                    navigationCoordinator.selectedTab = .home
                }
            )
        }
        .sheet(isPresented: $showStartPicker) {
            PhotoStartPickerView(photoRepository: photoRepository) { offset in
                Task { await viewModel.startNewSession(startOffset: offset) }
            }
        }
        .alert("이전 위치에서 계속할까요?", isPresented: $viewModel.showResumeAlert) {
            Button("이어서 하기") {
                Task { await viewModel.resumeFromSavedIndex() }
            }
            Button("처음부터") {
                Task { await viewModel.startFresh() }
            }
        } message: {
            Text("이전에 \(viewModel.pendingResumeIndex)번째 사진까지 진행했습니다.")
        }
    }

    @ViewBuilder
    private var cleanContent: some View {
        switch viewModel.screenState {
        case .idle:
            idleView
        case .cleaning:
            CleaningActiveView(viewModel: viewModel)
        case .summary(let session):
            SessionSummaryView(
                session: session,
                onReviewDeletionQueue: {
                    showDeletionQueue = true
                },
                onDone: {
                    viewModel.returnToIdle()
                }
            )
        }
    }

    private var idleView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                Text("스와이프 정리")
                    .font(.title.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.sm)

                VStack(spacing: AppSpacing.sm) {
                    cleaningModeButton(
                        title: "전체사진",
                        subtitle: "모든 사진을 순서대로 정리",
                        icon: "photo.on.rectangle",
                        color: AppColors.textPrimary
                    ) {
                        Task { await viewModel.startNewSession() }
                    }

                    cleaningModeButton(
                        title: "스크린샷",
                        subtitle: "스크린샷만 빠르게 정리",
                        icon: "camera.viewfinder",
                        color: AppColors.textSecondary
                    ) {
                        Task { await viewModel.startNewSession(filter: .screenshotsOnly()) }
                    }

                    cleaningModeButton(
                        title: "동영상",
                        subtitle: "용량 큰 동영상 정리",
                        icon: "video.fill",
                        color: AppColors.textSecondary
                    ) {
                        Task { await viewModel.startNewSession(filter: .videosOnly()) }
                    }

                    cleaningModeButton(
                        title: "시작위치 선택하기",
                        subtitle: "특정 시점부터 정리 시작",
                        icon: "photo.on.rectangle.angled",
                        color: AppColors.textSecondary
                    ) {
                        showStartPicker = true
                    }

                    cleaningModeButton(
                        title: "랜덤",
                        subtitle: "사진을 랜덤으로 섞어서 정리",
                        icon: "shuffle",
                        color: AppColors.textSecondary
                    ) {
                        Task { await viewModel.startNewSession(shuffled: true) }
                    }
                }
            }
            .padding(AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private func cleaningModeButton(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(AppColors.background, in: RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))

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
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.sm)
            .surfaceStyle()
        }
        .buttonStyle(.plain)
    }
}
