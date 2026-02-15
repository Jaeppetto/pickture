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

            if viewModel.currentIndex < viewModel.photos.count {
                topStatusBar
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
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
                .padding(.horizontal, AppSpacing.md)
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

    private var topStatusBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "shuffle")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Text(captureTimeText)
                .font(AppTypography.captionMedium)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            HStack(spacing: AppSpacing.xxxs) {
                Image(systemName: "photo")
                Text("\(remainingCount)")
            }
            .font(AppTypography.captionMedium)
            .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.surface, in: Capsule())
        .overlay {
            Capsule().stroke(AppColors.cardBorder, lineWidth: 1)
        }
    }

    private var remainingCount: Int {
        max(0, viewModel.photos.count - viewModel.currentIndex)
    }

    private var captureTimeText: String {
        guard viewModel.currentIndex < viewModel.photos.count else { return "--:--" }
        return Self.timeFormatter.string(from: viewModel.photos[viewModel.currentIndex].createdAt)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

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

            actionButton(icon: "star.fill", color: AppColors.favorite, size: 40) {
                Task { await viewModel.favoriteCurrentPhoto() }
            }

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
