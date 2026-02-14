import SwiftUI

struct SwipeCardView: View {
    let photo: Photo
    let thumbnail: UIImage?
    let onSwiped: (Decision) -> Void
    let onTapped: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isRemoved = false

    private let swipeThreshold: CGFloat = 120
    private let verticalThreshold: CGFloat = -100

    var body: some View {
        ZStack {
            cardImage
            directionOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .rotationEffect(.degrees(Double(offset.width) / 20.0))
        .offset(x: offset.width, y: offset.height)
        .opacity(isRemoved ? 0 : 1)
        .gesture(dragGesture)
        .onTapGesture { onTapped() }
    }

    // MARK: - Card Image

    private var cardImage: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(AppColors.surface)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    // MARK: - Direction Overlay

    @ViewBuilder
    private var directionOverlay: some View {
        // Delete overlay (swipe left)
        if offset.width < -30 {
            overlayBadge(
                gradient: AppColors.deleteGradient,
                icon: "trash.fill",
                text: "삭제",
                alignment: .topTrailing,
                opacity: min(1, abs(offset.width) / swipeThreshold)
            )
        }

        // Keep overlay (swipe right)
        if offset.width > 30 {
            overlayBadge(
                gradient: AppColors.keepGradient,
                icon: "checkmark.circle.fill",
                text: "보관",
                alignment: .topLeading,
                opacity: min(1, offset.width / swipeThreshold)
            )
        }

        // Favorite overlay (swipe up)
        if offset.height < -30 {
            overlayBadge(
                gradient: AppColors.favoriteGradient,
                icon: "star.fill",
                text: "즐겨찾기",
                alignment: .bottom,
                opacity: min(1, abs(offset.height) / abs(verticalThreshold))
            )
        }
    }

    private func overlayBadge(
        gradient: LinearGradient,
        icon: String,
        text: String,
        alignment: Alignment,
        opacity: Double
    ) -> some View {
        ZStack(alignment: alignment) {
            Color.clear

            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: icon)
                Text(text)
            }
            .font(AppTypography.title3)
            .foregroundStyle(.white)
            .padding(AppSpacing.sm)
            .background(gradient.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))
            .padding(AppSpacing.md)
        }
        .opacity(opacity)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                let direction = resolveDirection(translation: value.translation)

                if let direction {
                    withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
                        applyFinalOffset(for: direction)
                        isRemoved = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwiped(direction)
                    }
                } else {
                    withAnimation(.spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)) {
                        offset = .zero
                    }
                }
            }
    }

    private func resolveDirection(translation: CGSize) -> Decision? {
        if translation.height < verticalThreshold {
            return .favorite
        }
        if translation.width < -swipeThreshold {
            return .delete
        }
        if translation.width > swipeThreshold {
            return .keep
        }
        return nil
    }

    private func applyFinalOffset(for decision: Decision) {
        switch decision {
        case .delete:
            offset = CGSize(width: -500, height: 0)
        case .keep:
            offset = CGSize(width: 500, height: 0)
        case .favorite:
            offset = CGSize(width: 0, height: -600)
        }
    }
}
