import Foundation
import UIKit

protocol PhotoRepositoryProtocol: Sendable {
    func requestAuthorization() async -> PhotoAuthorizationStatus
    func checkAuthorizationStatus() -> PhotoAuthorizationStatus
    func fetchPhotos(offset: Int, limit: Int, filter: CleaningFilter?) async throws -> [Photo]
    func fetchPhotoCount(filter: CleaningFilter?) async throws -> Int
    func observePhotoLibraryChanges() -> AsyncStream<Void>
    func requestThumbnail(for photoId: String, size: CGSize) async -> UIImage?
    func requestPreviewImage(for photoId: String, size: CGSize) async -> UIImage?
    func startCachingThumbnails(for photoIds: [String], targetSize: CGSize) async
    func stopCachingThumbnails(for photoIds: [String], targetSize: CGSize) async
}

enum PhotoAuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case limited
    case denied
    case restricted
}
