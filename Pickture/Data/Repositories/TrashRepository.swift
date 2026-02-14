import Foundation

final class TrashRepository: TrashRepositoryProtocol, @unchecked Sendable {
    init() {}

    func addToTrash(photoId: String, fileSize: Int64) async throws -> TrashItem {
        // Stub
        TrashItem(photoId: photoId, fileSize: fileSize)
    }

    func getTrashItems() async throws -> [TrashItem] {
        // Stub
        []
    }

    func restoreFromTrash(id: String) async throws {
        // Stub
    }

    func permanentlyDelete(id: String) async throws {
        // Stub
    }

    func emptyTrash() async throws {
        // Stub
    }

    func removeExpiredItems() async throws -> Int {
        // Stub
        0
    }

    func getTrashStorageBytes() async throws -> Int64 {
        // Stub
        0
    }
}
