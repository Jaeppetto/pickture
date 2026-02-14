import Foundation
import Photos

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
        // Note: This synchronous call is safe for PHAuthorizationStatus check
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status.toDomain
    }

    func fetchPhotos(offset: Int, limit: Int, filter: CleaningFilter?) async throws -> [Photo] {
        // Stub: will be fully implemented in Phase 2
        []
    }

    func fetchPhotoCount(filter: CleaningFilter?) async throws -> Int {
        // Stub: will be fully implemented in Phase 2
        0
    }

    func observePhotoLibraryChanges() -> AsyncStream<Void> {
        // Stub: will be fully implemented in Phase 2
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
