import SwiftUI

struct PhotoMetadataOverlay: View {
    let photo: Photo
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("상세 정보")
                        .font(AppTypography.title3)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Divider()
                    .background(.white.opacity(0.3))

                metadataRow(icon: "calendar", label: "날짜", value: formattedDate)
                metadataRow(icon: "arrow.up.left.and.arrow.down.right", label: "해상도", value: "\(photo.pixelWidth) x \(photo.pixelHeight)")
                metadataRow(icon: "doc", label: "파일 크기", value: photo.fileSize.formattedBytes)
                metadataRow(icon: "photo", label: "종류", value: photoTypeName)

                if let duration = photo.duration, duration > 0 {
                    metadataRow(icon: "clock", label: "길이", value: formattedDuration(duration))
                }

                if photo.location != nil {
                    metadataRow(icon: "location", label: "위치", value: "위치 정보 있음")
                }
            }
            .padding(AppSpacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large))
            .padding(AppSpacing.md)
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture { onDismiss() }
    }

    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 20)
            Text(label)
                .font(AppTypography.footnote)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(AppTypography.footnoteMedium)
                .foregroundStyle(.white)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: photo.createdAt)
    }

    private var photoTypeName: String {
        switch photo.type {
        case .image: "사진"
        case .video: "동영상"
        case .screenshot: "스크린샷"
        case .gif: "GIF"
        case .livePhoto: "라이브 포토"
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
