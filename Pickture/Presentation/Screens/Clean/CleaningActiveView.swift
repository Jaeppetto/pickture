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
                        }
                    )
                } else if viewModel.isLoadingPhotos {
                    cardSkeleton
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Action buttons
            actionBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: AppSpacing.lg) {
            actionButton(icon: "trash.fill", color: AppColors.delete, size: 44) {
                Task { await viewModel.deleteCurrentPhoto() }
            }

            actionButton(icon: "arrow.uturn.backward", color: .white.opacity(0.86), size: 40) {
                Task { await viewModel.undoLastDecision() }
            }
            .opacity(viewModel.canUndo ? 1 : 0.35)
            .disabled(!viewModel.canUndo)

            actionButton(icon: "checkmark", color: AppColors.keep, size: 44) {
                Task { await viewModel.keepCurrentPhoto() }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.chrome, in: Capsule())
        .overlay {
            Capsule().stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
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
                .background(Circle().fill(.white.opacity(0.08)))
                .overlay(Circle().stroke(.white.opacity(0.08), lineWidth: 1))
        }
        .disabled(viewModel.currentIndex >= viewModel.photos.count)
    }

    // MARK: - Card Skeleton

    private var cardSkeleton: some View {
        RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
            .fill(AppColors.surface)
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
                    .strokeBorder(AppColors.cardBorder, lineWidth: 1)
            }
            .padding(.horizontal, AppSpacing.lg)
            .shimmer()
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
            .subtleButton()
            .padding(.horizontal, AppSpacing.xxl)
        }
    }
}
