import SwiftUI

struct CleanScreen: View {
    @State var viewModel: CleanViewModel
    @State var permissionViewModel: PhotoPermissionViewModel
    var navigationCoordinator: NavigationCoordinator
    var deletionQueueViewModelFactory: () -> DeletionQueueViewModel
    var photoRepository: any PhotoRepositoryProtocol

    @State private var showFilterSheet = false
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
        .sheet(isPresented: $showFilterSheet) {
            FilterSelectionSheet { filter in
                Task { await viewModel.startNewSession(filter: filter) }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showDeletionQueue) {
            DeletionQueueScreen(viewModel: deletionQueueViewModelFactory())
        }
        .sheet(isPresented: $showStartPicker) {
            PhotoStartPickerView(photoRepository: photoRepository) { offset in
                Task { await viewModel.startNewSession(startOffset: offset) }
            }
        }
    }

    @ViewBuilder
    private var cleanContent: some View {
        switch viewModel.screenState {
        case .idle:
            idleView
        case .filterSelection:
            idleView
                .onAppear { showFilterSheet = true }
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
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.primaryGradient)

            VStack(spacing: AppSpacing.xs) {
                Text("사진 정리")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.textPrimary)

                Text("스와이프로 빠르게 정리하세요")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            VStack(spacing: AppSpacing.sm) {
                Button {
                    showFilterSheet = true
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "sparkles")
                        Text("정리 시작")
                    }
                    .glassPrimaryButton()
                }

                Button {
                    Task { await viewModel.startNewSession() }
                } label: {
                    Text("필터 없이 바로 시작")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primary)
                }

                Button {
                    showStartPicker = true
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "photo.on.rectangle")
                        Text("시작 위치 선택하기")
                    }
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.xxl)

            Spacer()
        }
    }
}
