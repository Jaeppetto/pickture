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
            actionButton(icon: "trash.fill", bgColor: AppColors.accentRed, fgColor: .white, size: 52) {
                Task { await viewModel.deleteCurrentPhoto() }
            }

            actionButton(icon: "arrow.uturn.backward", bgColor: AppColors.surface, fgColor: AppColors.ink, size: 44) {
                Task { await viewModel.undoLastDecision() }
            }
            .opacity(viewModel.canUndo ? 1 : 0.35)
            .disabled(!viewModel.canUndo)

            actionButton(icon: "checkmark", bgColor: AppColors.accentGreen, fgColor: .white, size: 52) {
                Task { await viewModel.keepCurrentPhoto() }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(AppColors.surface)
        )
        .overlay {
            Capsule().strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidthThick)
        }
        .background(
            Capsule()
                .fill(AppColors.shadowColor)
                .offset(x: AppSpacing.BrutalistTokens.shadowOffset, y: AppSpacing.BrutalistTokens.shadowOffset)
        )
    }

    private func actionButton(
        icon: String,
        bgColor: Color,
        fgColor: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticManager.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(fgColor)
                .frame(width: size, height: size)
                .background(Circle().fill(bgColor))
                .overlay(Circle().strokeBorder(AppColors.border, lineWidth: 2))
        }
        .disabled(viewModel.currentIndex >= viewModel.photos.count)
    }

    // MARK: - Card Skeleton

    private var cardSkeleton: some View {
        RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
            .fill(AppColors.surface)
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
            }
            .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.keep)

            Text("정리할 사진이 없습니다")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.ink)

            Button("세션 완료") {
                Task { await viewModel.completeSession() }
            }
            .buttonStyle(.brutalistSecondary)
            .padding(.horizontal, AppSpacing.xxl)
        }
    }
}
