import SwiftUI

struct SwipeCardView: View {
    let photo: Photo
    let thumbnail: UIImage?
    let onSwiped: (Decision) -> Void

    @Environment(\.locale) private var locale
    @State private var offset: CGSize = .zero
    @State private var isRemoved = false
    @State private var appeared = false

    private let swipeThreshold: CGFloat = 120
    private let shape = RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)

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
            shape.strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
        }
        .background(
            shape
                .fill(AppColors.shadowColor)
                .offset(x: AppSpacing.BrutalistTokens.shadowOffset, y: AppSpacing.BrutalistTokens.shadowOffsetLarge)
        )
        .scaleEffect(appeared ? 1.0 : 0.965)
        .offset(y: appeared ? 0 : 12)
        .rotationEffect(.degrees(Double(offset.width) / 20.0))
        .offset(x: offset.width, y: offset.height)
        .opacity(isRemoved ? 0 : 1)
        .contentShape(shape)
        .highPriorityGesture(dragGesture)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                appeared = true
            }
        }
    }

    // MARK: - Card Image

    private var cardImage: some View {
        Color.clear
            .overlay {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .clipped()
            .background(AppColors.surface)
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
            stampOverlay(
                text: String(localized: "삭제", locale: locale),
                color: AppColors.delete,
                rotation: 12,
                progress: min(1, abs(offset.width) / swipeThreshold)
            )
        }

        if offset.width > 30 {
            stampOverlay(
                text: String(localized: "보관", locale: locale),
                color: AppColors.keep,
                rotation: -12,
                progress: min(1, offset.width / swipeThreshold)
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
            .background(
                Capsule()
                    .fill(AppColors.surface)
                    .overlay {
                        Capsule().strokeBorder(AppColors.border, lineWidth: 1.5)
                    }
            )
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
        .foregroundStyle(AppColors.ink)
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.vertical, AppSpacing.xxs)
    }

    private func stampOverlay(
        text: String,
        color: Color,
        rotation: Double,
        progress: Double
    ) -> some View {
        ZStack {
            Text(text)
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(color)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall, style: .continuous)
                        .strokeBorder(color, lineWidth: 4)
                }
                .rotationEffect(.degrees(rotation))
                .scaleEffect(0.6 + progress * 0.4)
        }
        .opacity(progress)
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        applyFinalOffset(for: direction)
                        isRemoved = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwiped(direction)
                    }
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        offset = .zero
                    }
                }
            }
    }

    private func resolveDirection(translation: CGSize) -> Decision? {
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
        }
    }

    private var activeDecision: Decision? {
        if offset.width < -30 {
            return .delete
        }
        if offset.width > 30 {
            return .keep
        }
        return nil
    }

    private var tintOpacity: Double {
        let progress = abs(offset.width) / swipeThreshold
        return min(0.08, progress * 0.08)
    }

    private func decisionColor(_ decision: Decision) -> Color {
        switch decision {
        case .delete: AppColors.delete
        case .keep: AppColors.keep
        }
    }

    private var photoTypeText: String {
        switch photo.type {
        case .image: String(localized: "사진", locale: locale)
        case .video: String(localized: "동영상", locale: locale)
        case .screenshot: String(localized: "스크린샷", locale: locale)
        case .gif: String(localized: "GIF", locale: locale)
        case .livePhoto: String(localized: "Live", locale: locale)
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
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = locale
        return formatter.string(from: photo.createdAt)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
