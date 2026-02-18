import SwiftUI

struct PhotoMetadataOverlay: View {
    let photo: Photo
    let onDismiss: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("상세 정보")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.ink)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(AppColors.ink)
                            .frame(width: 32, height: 32)
                            .background(AppColors.background, in: Circle())
                            .overlay {
                                Circle().strokeBorder(AppColors.border, lineWidth: 2)
                            }
                    }
                }
                .padding(AppSpacing.md)

                divider

                metadataRow(icon: "calendar", label: "날짜", value: formattedDate)
                divider
                metadataRow(icon: "arrow.up.left.and.arrow.down.right", label: "해상도", value: "\(photo.pixelWidth) x \(photo.pixelHeight)")
                divider
                metadataRow(icon: "doc", label: "파일 크기", value: photo.fileSize.formattedBytes)
                divider
                metadataRow(icon: "photo", label: "종류", value: photoTypeName)

                if let duration = photo.duration, duration > 0 {
                    divider
                    metadataRow(icon: "clock", label: "길이", value: formattedDuration(duration))
                }

                if photo.location != nil {
                    divider
                    metadataRow(icon: "location", label: "위치", value: String(localized: "위치 정보 있음", locale: locale))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
            }
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)
                    .fill(AppColors.shadowColor)
                    .offset(x: AppSpacing.BrutalistTokens.shadowOffset, y: AppSpacing.BrutalistTokens.shadowOffset)
            )
            .padding(AppSpacing.md)
        }
        .background(AppColors.overlayScrim)
        .onTapGesture { onDismiss() }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(height: 1)
    }

    private func metadataRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.inkMuted)
                .frame(width: 20)
            Text(label)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.inkMuted)
            Spacer()
            Text(value)
                .font(AppTypography.footnoteMedium)
                .foregroundStyle(AppColors.ink)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
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
