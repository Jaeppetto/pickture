import Foundation
import Photos
import UIKit

actor PhotoLibraryDataSource {
    private let imageManager: PHCachingImageManager
    private var changeObserverHelper: PhotoLibraryChangeObserverHelper?
    private var assetCache: [String: PHAsset] = [:]
    private var currentFetchResult: PHFetchResult<PHAsset>?
    private var currentFetchFilter: CleaningFilter?

    init() {
        self.imageManager = PHCachingImageManager()
        self.imageManager.allowsCachingHighQualityImages = false
    }

    // MARK: - Authorization

    func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    func checkAuthorizationStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    // MARK: - Fetching

    func fetchAssets(offset: Int, limit: Int, filter: CleaningFilter?) -> PHFetchResult<PHAsset> {
        let fetchResult: PHFetchResult<PHAsset>

        if let cached = currentFetchResult, currentFetchFilter == filter {
            fetchResult = cached
        } else {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

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

            fetchResult = PHAsset.fetchAssets(with: options)
            currentFetchResult = fetchResult
            currentFetchFilter = filter
        }

        // Populate asset cache for accessed range
        let startIndex = min(offset, fetchResult.count)
        let endIndex = min(offset + limit, fetchResult.count)
        if startIndex < endIndex {
            for index in startIndex..<endIndex {
                let asset = fetchResult.object(at: index)
                assetCache[asset.localIdentifier] = asset
            }
        }

        return fetchResult
    }

    func fetchAssetCount(filter: CleaningFilter?) -> Int {
        let options = PHFetchOptions()
        options.fetchLimit = 0

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

        return PHAsset.fetchAssets(with: options).count
    }

    func fetchAssetsByIdentifiers(_ identifiers: [String]) -> [PHAsset] {
        let result = PHAsset.fetchAssets(
            withLocalIdentifiers: identifiers,
            options: nil
        )
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    // MARK: - Image Loading

    func requestThumbnail(assetId: String, size: CGSize) async -> UIImage? {
        guard let asset = resolveAsset(id: assetId) else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast

        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func requestPreviewImage(assetId: String, size: CGSize) async -> UIImage? {
        guard let asset = resolveAsset(id: assetId) else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast

        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    // MARK: - Caching

    func startCaching(assetIds: [String], targetSize: CGSize) {
        let assets = resolveAssets(ids: assetIds)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        imageManager.startCachingImages(
            for: assets,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        )
    }

    func stopCaching(assetIds: [String], targetSize: CGSize) {
        let assets = resolveAssets(ids: assetIds)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        imageManager.stopCachingImages(
            for: assets,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        )
    }

    func stopCachingAll() {
        imageManager.stopCachingImagesForAllAssets()
    }

    func invalidateCache() {
        assetCache.removeAll()
        currentFetchResult = nil
        currentFetchFilter = nil
        imageManager.stopCachingImagesForAllAssets()
    }

    // MARK: - Asset Resolution

    private func resolveAsset(id: String) -> PHAsset? {
        if let cached = assetCache[id] {
            return cached
        }
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
    }

    private func resolveAssets(ids: [String]) -> [PHAsset] {
        var resolved: [PHAsset] = []
        var missingIds: [String] = []

        for id in ids {
            if let cached = assetCache[id] {
                resolved.append(cached)
            } else {
                missingIds.append(id)
            }
        }

        if !missingIds.isEmpty {
            let fetched = fetchAssetsByIdentifiers(missingIds)
            for asset in fetched {
                assetCache[asset.localIdentifier] = asset
            }
            resolved.append(contentsOf: fetched)
        }

        return resolved
    }

    // MARK: - Change Observation

    func observePhotoLibraryChanges() -> AsyncStream<Void> {
        let helper = PhotoLibraryChangeObserverHelper()
        self.changeObserverHelper = helper
        return helper.stream
    }

    // MARK: - Storage Calculation (Sampling-Based)

    func calculateStorageByType() async -> (
        photoCount: Int, videoCount: Int, screenshotCount: Int,
        photoBytes: Int64, videoBytes: Int64, screenshotBytes: Int64, otherBytes: Int64
    ) {
        let photoCount = fetchAssetCount(filter: CleaningFilter(photoType: .image))
        let videoCount = fetchAssetCount(filter: CleaningFilter(photoType: .video))
        let screenshotCount = fetchAssetCount(filter: CleaningFilter(photoType: .screenshot))

        // Sampling-based size estimation: sample up to 50 assets per category
        let sampleSize = 50
        let photoBytes = estimateCategoryBytes(filter: CleaningFilter(photoType: .image), count: photoCount, sampleSize: sampleSize)
        let videoBytes = estimateCategoryBytes(filter: CleaningFilter(photoType: .video), count: videoCount, sampleSize: sampleSize)
        let screenshotBytes = estimateCategoryBytes(filter: CleaningFilter(photoType: .screenshot), count: screenshotCount, sampleSize: sampleSize)

        // "Other" = GIFs + live photos
        let allCount = fetchAssetCount(filter: nil)
        let otherCount = max(0, allCount - photoCount - videoCount - screenshotCount)
        let otherBytes = Int64(otherCount) * 2_500_000 // ~2.5MB average fallback

        return (photoCount, videoCount, screenshotCount, photoBytes, videoBytes, screenshotBytes, otherBytes)
    }

    private func estimateCategoryBytes(filter: CleaningFilter, count: Int, sampleSize: Int) -> Int64 {
        guard count > 0 else { return 0 }

        let fetchLimit = min(count, sampleSize)
        let result = fetchAssets(offset: 0, limit: fetchLimit, filter: filter)

        var totalSampleBytes: Int64 = 0
        var sampleCount = 0

        result.enumerateObjects { asset, index, stop in
            if index >= fetchLimit {
                stop.pointee = true
                return
            }
            let resources = PHAssetResource.assetResources(for: asset)
            if let resource = resources.first,
               let size = resource.value(forKey: "fileSize") as? Int64 {
                totalSampleBytes += size
            } else {
                // Fallback estimate
                let bytesPerPixel: Int64 = asset.mediaType == .video ? 4 : 3
                totalSampleBytes += Int64(asset.pixelWidth) * Int64(asset.pixelHeight) * bytesPerPixel
            }
            sampleCount += 1
        }

        guard sampleCount > 0 else { return 0 }
        let averageBytes = totalSampleBytes / Int64(sampleCount)
        return averageBytes * Int64(count)
    }

    // MARK: - Deletion

    func deleteAssets(identifiers: [String]) async throws {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        }
    }
}

// MARK: - Photo Library Change Observer Helper

private final class PhotoLibraryChangeObserverHelper: NSObject, PHPhotoLibraryChangeObserver, Sendable {
    let stream: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation

    override init() {
        var storedContinuation: AsyncStream<Void>.Continuation!
        self.stream = AsyncStream { continuation in
            storedContinuation = continuation
        }
        self.continuation = storedContinuation
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        continuation.finish()
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        continuation.yield()
    }
}
