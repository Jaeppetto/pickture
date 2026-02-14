import Foundation

protocol PhotoRepositoryProtocol: Sendable {
    func requestAuthorization() async -> PhotoAuthorizationStatus
    func checkAuthorizationStatus() -> PhotoAuthorizationStatus
    func fetchPhotos(offset: Int, limit: Int, filter: CleaningFilter?) async throws -> [Photo]
    func fetchPhotoCount(filter: CleaningFilter?) async throws -> Int
    func observePhotoLibraryChanges() -> AsyncStream<Void>
}

enum PhotoAuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case limited
    case denied
    case restricted
}
