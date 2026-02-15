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
    private let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)

    var body: some View {
        ZStack {
            cardImage
            decisionTintOverlay
            metadataOverlay
            directionOverlay
                .allowsHitTesting(false)
        }
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(AppColors.cardBorder, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .rotationEffect(.degrees(Double(offset.width) / 20.0))
        .offset(x: offset.width, y: offset.height)
        .opacity(isRemoved ? 0 : 1)
        .contentShape(shape)
        .highPriorityGesture(dragGesture)
        .onTapGesture { onTapped() }
    }

    // MARK: - Card Image

    private var cardImage: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .fill(AppColors.surface)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.surface)
        .clipped()
    }

    @ViewBuilder
    private var decisionTintOverlay: some View {
        if let decision = activeDecision {
            decisionColor(decision)
                .opacity(tintOpacity)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var directionOverlay: some View {
        if offset.width < -30 {
            overlayBadge(
                gradient: AppColors.deleteGradient,
                icon: "trash.fill",
                text: "삭제",
                alignment: .topTrailing,
                opacity: min(1, abs(offset.width) / swipeThreshold)
            )
        }

        if offset.width > 30 {
            overlayBadge(
                gradient: AppColors.keepGradient,
                icon: "checkmark.circle.fill",
                text: "보관",
                alignment: .topLeading,
                opacity: min(1, offset.width / swipeThreshold)
            )
        }

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

    private var metadataOverlay: some View {
        VStack {
            Spacer()

            HStack(spacing: AppSpacing.xs) {
                metadataChip(icon: photoTypeIcon, text: photoTypeText)
                metadataChip(icon: "calendar", text: formattedDate)
                Spacer()
                if let duration = photo.duration, duration > 0 {
                    metadataChip(icon: "play.fill", text: formattedDuration(duration))
                }
                metadataChip(icon: "internaldrive", text: photo.fileSize.formattedBytesShort)
            }
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xs)
            .background(.regularMaterial, in: Capsule())
        }
        .padding(AppSpacing.sm)
        .allowsHitTesting(false)
    }

    private func metadataChip(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.xxxs) {
            Image(systemName: icon)
            Text(text)
        }
        .font(AppTypography.captionMedium)
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.vertical, AppSpacing.xxs)
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
            .font(AppTypography.bodySemibold)
            .foregroundStyle(.white)
            .padding(AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small, style: .continuous)
                    .fill(gradient.opacity(0.9))
            )
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

    private var activeDecision: Decision? {
        if offset.height < -30 {
            return .favorite
        }
        if offset.width < -30 {
            return .delete
        }
        if offset.width > 30 {
            return .keep
        }
        return nil
    }

    private var tintOpacity: Double {
        let horizontal = abs(offset.width) / swipeThreshold
        let vertical = abs(offset.height) / abs(verticalThreshold)
        return min(0.08, max(horizontal, vertical) * 0.08)
    }

    private func decisionColor(_ decision: Decision) -> Color {
        switch decision {
        case .delete: AppColors.delete
        case .keep: AppColors.keep
        case .favorite: AppColors.favorite
        }
    }

    private var photoTypeText: String {
        switch photo.type {
        case .image: "사진"
        case .video: "동영상"
        case .screenshot: "스크린샷"
        case .gif: "GIF"
        case .livePhoto: "Live"
        }
    }

    private var photoTypeIcon: String {
        switch photo.type {
        case .image: "photo"
        case .video: "video.fill"
        case .screenshot: "camera.viewfinder"
        case .gif: "square.stack.3d.forward.dottedline"
        case .livePhoto: "livephoto"
        }
    }

    private var formattedDate: String {
        Self.dateFormatter.string(from: photo.createdAt)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
