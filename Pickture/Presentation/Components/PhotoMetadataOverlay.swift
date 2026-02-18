import SwiftUI

struct PhotoMetadataOverlay: View {
    let photo: Photo
    let onDismiss: () -> Void

    @Environment(\.locale) private var locale

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
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.72))
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
                    metadataRow(icon: "location", label: "위치", value: String(localized: "위치 정보 있음", locale: locale))
                }
            }
            .padding(AppSpacing.md)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.overlayScrim)
        .onTapGesture { onDismiss() }
    }

    private func metadataRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
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
        formatter.locale = locale
        return formatter.string(from: photo.createdAt)
    }

    private var photoTypeName: String {
        switch photo.type {
        case .image: String(localized: "사진", locale: locale)
        case .video: String(localized: "동영상", locale: locale)
        case .screenshot: String(localized: "스크린샷", locale: locale)
        case .gif: String(localized: "GIF", locale: locale)
        case .livePhoto: String(localized: "라이브 포토", locale: locale)
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
