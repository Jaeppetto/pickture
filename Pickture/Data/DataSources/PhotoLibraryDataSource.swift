import Foundation
import Photos

actor PhotoLibraryDataSource {
    private let imageManager: PHCachingImageManager

    init() {
        self.imageManager = PHCachingImageManager()
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    func checkAuthorizationStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func fetchAssets(offset: Int, limit: Int, filter: CleaningFilter?) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = offset + limit

        if let filter {
            var predicates: [NSPredicate] = []

            if let photoType = filter.photoType {
                switch photoType {
                case .video:
                    predicates.append(NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue))
                case .image, .livePhoto, .gif:
                    predicates.append(NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue))
                case .screenshot:
                    predicates.append(NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue))
                    predicates.append(NSPredicate(
                        format: "(mediaSubtypes & %d) != 0",
                        PHAssetMediaSubtype.photoScreenshot.rawValue
                    ))
                }
            }

            if let dateRange = filter.dateRange {
                predicates.append(NSPredicate(
                    format: "creationDate >= %@ AND creationDate <= %@",
                    dateRange.lowerBound as NSDate,
                    dateRange.upperBound as NSDate
                ))
            }

            if !predicates.isEmpty {
                options.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
        }

        return PHAsset.fetchAssets(with: options)
    }

    func fetchAssetCount(filter: CleaningFilter?) -> Int {
        let result = fetchAssets(offset: 0, limit: 0, filter: filter)
        return result.count
    }
}
