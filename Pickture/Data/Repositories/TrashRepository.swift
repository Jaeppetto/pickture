import Foundation
import Photos

final class TrashRepository: TrashRepositoryProtocol, @unchecked Sendable {
    private let localStorage: LocalStorageDataSource
    private let photoDataSource: PhotoLibraryDataSource

    init(localStorage: LocalStorageDataSource, photoDataSource: PhotoLibraryDataSource) {
        self.localStorage = localStorage
        self.photoDataSource = photoDataSource
    }

    func addToTrash(photoId: String, fileSize: Int64) async throws -> TrashItem {
        let item = TrashItem(photoId: photoId, fileSize: fileSize)
        try await localStorage.saveTrashItem(item)
        return item
    }

    func getTrashItems() async throws -> [TrashItem] {
        await localStorage.loadTrashItems().filter { !$0.isExpired }
    }

    func restoreFromTrash(id: String) async throws {
        try await localStorage.removeTrashItem(id: id)
    }

    func permanentlyDelete(id: String) async throws {
        let items = await localStorage.loadTrashItems()
        guard let item = items.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        try await photoDataSource.deleteAssets(identifiers: [item.photoId])
        try await localStorage.removeTrashItem(id: id)
    }

    func permanentlyDeleteBatch(ids: Set<String>) async throws {
        let items = await localStorage.loadTrashItems()
        let selected = items.filter { ids.contains($0.id) }
        let photoIds = selected.map(\.photoId)

        if !photoIds.isEmpty {
            try await photoDataSource.deleteAssets(identifiers: photoIds)
        }

        for id in ids {
            try await localStorage.removeTrashItem(id: id)
        }
    }

    func emptyTrash() async throws {
        let items = await localStorage.loadTrashItems()
        let photoIds = items.map(\.photoId)
        if !photoIds.isEmpty {
            try await photoDataSource.deleteAssets(identifiers: photoIds)
        }
        await localStorage.clearAllTrashItems()
    }

    func removeExpiredItems() async throws -> Int {
        let items = await localStorage.loadTrashItems()
        let expired = items.filter(\.isExpired)
        for item in expired {
            try await localStorage.removeTrashItem(id: item.id)
        }
        return expired.count
    }

    func getTrashStorageBytes() async throws -> Int64 {
        let items = await localStorage.loadTrashItems()
        return items.filter { !$0.isExpired }.reduce(0) { $0 + $1.fileSize }
    }

    func getNearExpiringItems(withinDays days: Int) async throws -> [TrashItem] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: .now) ?? Date.now
        return await localStorage.loadTrashItems()
            .filter { !$0.isExpired && $0.expiresAt <= cutoff }
    }
}
