import Foundation
import Photos

extension PHAsset {
    func toDomain() -> Photo {
        let resources = PHAssetResource.assetResources(for: self)
        let photoType = resolvePhotoType(from: resources)
        let fileSize = estimateFileSize(from: resources)
        let coordinate: Coordinate? = if let loc = location {
            Coordinate(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        } else {
            nil
        }

        return Photo(
            id: localIdentifier,
            createdAt: creationDate ?? .distantPast,
            fileSize: fileSize,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            type: photoType,
            duration: mediaType == .video ? duration : nil,
            location: coordinate,
            isFavorite: isFavorite
        )
    }

    private func resolvePhotoType(from resources: [PHAssetResource]) -> PhotoType {
        switch mediaType {
        case .video:
            return .video
        case .image:
            if mediaSubtypes.contains(.photoScreenshot) {
                return .screenshot
            }
            if let uti = resources.first?.uniformTypeIdentifier, uti.contains("gif") {
                return .gif
            }
            if mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        default:
            return .image
        }
    }

    private func estimateFileSize(from resources: [PHAssetResource]) -> Int64 {
        guard let resource = resources.first else { return 0 }

        if let size = resource.value(forKey: "fileSize") as? Int64 {
            return size
        }

        // Fallback: estimate based on pixel dimensions
        let bytesPerPixel: Int64 = mediaType == .video ? 4 : 3
        return Int64(pixelWidth) * Int64(pixelHeight) * bytesPerPixel
    }
}
