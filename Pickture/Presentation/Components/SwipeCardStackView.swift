import SwiftUI

struct SwipeCardStackView: View {
    let photos: [Photo]
    let currentIndex: Int
    let thumbnails: [String: UIImage]
    let onSwiped: (Decision) -> Void

    private let visibleCardCount = 3

    var body: some View {
        ZStack {
            ForEach(visibleCards.reversed(), id: \.offset) { item in
                let stackOffset = item.offset - currentIndex

                if stackOffset == 0 {
                    SwipeCardView(
                        photo: item.element,
                        thumbnail: thumbnails[item.element.id],
                        onSwiped: onSwiped
                    )
                    .zIndex(Double(visibleCardCount - stackOffset))
                } else {
                    backgroundCard(for: item.element, at: stackOffset)
                        .zIndex(Double(visibleCardCount - stackOffset))
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
    }

    private var visibleCards: [(offset: Int, element: Photo)] {
        let start = currentIndex
        let end = min(currentIndex + visibleCardCount, photos.count)
        guard start < end else { return [] }
        return (start..<end).map { (offset: $0, element: photos[$0]) }
    }

    private func backgroundCard(for photo: Photo, at stackOffset: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)

        return Group {
            if let thumbnail = thumbnails[photo.id] {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .fill(AppColors.surface)
            }
        }
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.surface)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(AppColors.cardBorder, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .scaleEffect(1 - CGFloat(stackOffset) * 0.035)
        .offset(y: CGFloat(stackOffset) * 12)
        .opacity(1 - CGFloat(stackOffset) * 0.2)
        .allowsHitTesting(false)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
    }
}
