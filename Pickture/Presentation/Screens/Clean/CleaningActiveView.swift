import SwiftUI

struct CleaningActiveView: View {
    @Bindable var viewModel: CleanViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if let session = viewModel.currentSession {
                CleaningProgressView(
                    session: session,
                    totalPhotos: viewModel.totalPhotoCount
                )
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
            }

            // Card stack
            ZStack {
                if viewModel.currentIndex < viewModel.photos.count {
                    SwipeCardStackView(
                        photos: viewModel.photos,
                        currentIndex: viewModel.currentIndex,
                        thumbnails: viewModel.thumbnails,
                        onSwiped: { decision in
                            Task { await viewModel.processSwipe(decision) }
                        },
                        onTapped: { photo in
                            viewModel.showMetadata(for: photo)
                        }
                    )
                } else if viewModel.isLoadingPhotos {
                    ProgressView("사진 로딩 중...")
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Action buttons
            actionBar
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.md)
        }
        .overlay {
            if let photo = viewModel.selectedMetadataPhoto {
                PhotoMetadataOverlay(photo: photo) {
                    viewModel.hideMetadata()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: AppConstants.Animation.quickDuration), value: viewModel.selectedMetadataPhoto != nil)
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: AppSpacing.xxl) {
            // Delete button
            actionButton(
                icon: "trash.fill",
                color: AppColors.delete,
                size: 56
            ) {
                Task { await viewModel.deleteCurrentPhoto() }
            }

            // Undo button
            actionButton(
                icon: "arrow.uturn.backward",
                color: AppColors.textSecondary,
                size: 44
            ) {
                Task { await viewModel.undoLastDecision() }
            }
            .opacity(viewModel.canUndo ? 1 : 0.3)
            .disabled(!viewModel.canUndo)

            // Favorite button
            actionButton(
                icon: "star.fill",
                color: AppColors.favorite,
                size: 44
            ) {
                Task { await viewModel.favoriteCurrentPhoto() }
            }

            // Keep button
            actionButton(
                icon: "checkmark",
                color: AppColors.keep,
                size: 56
            ) {
                Task { await viewModel.keepCurrentPhoto() }
            }
        }
    }

    private func actionButton(
        icon: String,
        color: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticManager.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(AppColors.surface)
                        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
                )
        }
        .disabled(viewModel.currentIndex >= viewModel.photos.count)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.keep)

            Text("정리할 사진이 없습니다")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.textPrimary)

            Button("세션 완료") {
                Task { await viewModel.completeSession() }
            }
            .glassPrimaryButton()
            .padding(.horizontal, AppSpacing.xxl)
        }
    }
}
