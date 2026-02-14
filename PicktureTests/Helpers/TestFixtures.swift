import Foundation

@testable import Pickture

enum TestFixtures {
    static func makePhoto(
        id: String = "test-photo-1",
        fileSize: Int64 = 2_048_000,
        type: PhotoType = .image
    ) -> Photo {
        Photo(
            id: id,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            fileSize: fileSize,
            pixelWidth: 4032,
            pixelHeight: 3024,
            type: type
        )
    }

    static func makeSession(
        id: String = "test-session-1",
        status: SessionStatus = .active
    ) -> CleaningSession {
        CleaningSession(
            id: id,
            startedAt: Date(timeIntervalSince1970: 1_700_000_000),
            status: status
        )
    }

    static func makeTrashItem(
        photoId: String = "trash-photo-1",
        fileSize: Int64 = 1_024_000
    ) -> TrashItem {
        TrashItem(photoId: photoId, fileSize: fileSize)
    }
}
