import Foundation
import Photos
import UIKit

final class PhotoRepository: PhotoRepositoryProtocol, @unchecked Sendable {
    private let dataSource: PhotoLibraryDataSource

    init(dataSource: PhotoLibraryDataSource) {
        self.dataSource = dataSource
    }

    func requestAuthorization() async -> PhotoAuthorizationStatus {
        let status = await dataSource.requestAuthorization()
        return status.toDomain
    }

    func checkAuthorizationStatus() -> PhotoAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status.toDomain
    }

    func fetchPhotos(offset: Int, limit: Int, filter: CleaningFilter?) async throws -> [Photo] {
        let result = await dataSource.fetchAssets(offset: offset, limit: limit, filter: filter)
        var photos: [Photo] = []
        let startIndex = min(offset, result.count)
        let endIndex = min(offset + limit, result.count)

        guard startIndex < endIndex else { return [] }

        for index in startIndex..<endIndex {
            let asset = result.object(at: index)
            photos.append(asset.toDomain())
        }
        return photos
    }

    func fetchPhotosByIndices(_ indices: [Int], filter: CleaningFilter?) async throws -> [Photo] {
        let assets = await dataSource.fetchAssetsByIndices(indices, filter: filter)
        return assets.map { $0.toDomain() }
    }

    func fetchPhotoCount(filter: CleaningFilter?) async throws -> Int {
        await dataSource.fetchAssetCount(filter: filter)
    }

    func observePhotoLibraryChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                let stream = await dataSource.observePhotoLibraryChanges()
                for await change in stream {
                    continuation.yield(change)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func requestThumbnail(for photoId: String, size: CGSize) async -> UIImage? {
        await dataSource.requestThumbnail(assetId: photoId, size: size)
    }

    func requestPreviewImage(for photoId: String, size: CGSize) async -> UIImage? {
        await dataSource.requestPreviewImage(assetId: photoId, size: size)
    }

    func startCachingThumbnails(for photoIds: [String], targetSize: CGSize) async {
        await dataSource.startCaching(assetIds: photoIds, targetSize: targetSize)
    }

    func stopCachingThumbnails(for photoIds: [String], targetSize: CGSize) async {
        await dataSource.stopCaching(assetIds: photoIds, targetSize: targetSize)
    }

    func invalidateAssetCache() async {
        await dataSource.invalidateCache()
    }
}
