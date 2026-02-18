import Foundation

protocol TrashRepositoryProtocol: Sendable {
    func addToTrash(photoId: String, fileSize: Int64) async throws -> TrashItem
    func getTrashItems() async throws -> [TrashItem]
    func restoreFromTrash(id: String) async throws
    func permanentlyDelete(id: String) async throws
    func permanentlyDeleteBatch(ids: Set<String>) async throws
    func emptyTrash() async throws
    func removeExpiredItems() async throws -> Int
    func getTrashStorageBytes() async throws -> Int64
    func getNearExpiringItems(withinDays days: Int) async throws -> [TrashItem]
}
