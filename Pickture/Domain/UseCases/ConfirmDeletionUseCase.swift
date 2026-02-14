import Foundation

struct DeletionResult: Sendable {
    let deletedCount: Int
    let freedBytes: Int64
}

final class ConfirmDeletionUseCase: Sendable {
    private let trashRepository: any TrashRepositoryProtocol

    init(trashRepository: any TrashRepositoryProtocol) {
        self.trashRepository = trashRepository
    }

    func executeAll() async throws -> DeletionResult {
        let items = try await trashRepository.getTrashItems()
        let totalBytes = items.reduce(Int64(0)) { $0 + $1.fileSize }
        try await trashRepository.emptyTrash()
        return DeletionResult(deletedCount: items.count, freedBytes: totalBytes)
    }

    func executeSelected(ids: Set<String>) async throws -> DeletionResult {
        let items = try await trashRepository.getTrashItems()
        let selectedItems = items.filter { ids.contains($0.id) }
        var freedBytes: Int64 = 0

        for item in selectedItems {
            try await trashRepository.permanentlyDelete(id: item.id)
            freedBytes += item.fileSize
        }

        return DeletionResult(deletedCount: selectedItems.count, freedBytes: freedBytes)
    }
}
