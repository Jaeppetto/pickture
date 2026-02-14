import SwiftUI

struct SwipeCardStackView: View {
    let photos: [Photo]
    let currentIndex: Int
    let thumbnails: [String: UIImage]
    let onSwiped: (Decision) -> Void
    let onTapped: (Photo) -> Void

    private let visibleCardCount = 3

    var body: some View {
        ZStack {
            ForEach(visibleCards.reversed(), id: \.offset) { item in
                let stackOffset = item.offset - currentIndex

                if stackOffset == 0 {
                    SwipeCardView(
                        photo: item.element,
                        thumbnail: thumbnails[item.element.id],
                        onSwiped: onSwiped,
                        onTapped: { onTapped(item.element) }
                    )
                    .zIndex(Double(visibleCardCount - stackOffset))
                } else {
                    backgroundCard(for: item.element, at: stackOffset)
                        .zIndex(Double(visibleCardCount - stackOffset))
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var visibleCards: [(offset: Int, element: Photo)] {
        let start = currentIndex
        let end = min(currentIndex + visibleCardCount, photos.count)
        guard start < end else { return [] }
        return (start..<end).map { (offset: $0, element: photos[$0]) }
    }

    private func backgroundCard(for photo: Photo, at stackOffset: Int) -> some View {
        Group {
            if let thumbnail = thumbnails[photo.id] {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(AppColors.surface)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(1 - CGFloat(stackOffset) * 0.05)
        .offset(y: CGFloat(stackOffset) * 8)
        .opacity(1 - CGFloat(stackOffset) * 0.2)
        .allowsHitTesting(false)
    }
}
