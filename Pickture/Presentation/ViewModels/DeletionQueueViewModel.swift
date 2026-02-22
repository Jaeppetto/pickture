import Foundation
import UIKit

@Observable
@MainActor
final class DeletionQueueViewModel {
    private(set) var trashItems: [TrashItem] = []
    private(set) var thumbnails: [String: UIImage] = [:]
    private(set) var selectedIds: Set<String> = []
    private(set) var isLoading = false
    private(set) var isDeleting = false
    private(set) var deletionResult: DeletionResult?

    var hasSelection: Bool { !selectedIds.isEmpty }
    var allSelected: Bool { selectedIds.count == trashItems.count && !trashItems.isEmpty }
    var totalSelectedBytes: Int64 {
        trashItems.filter { selectedIds.contains($0.id) }.reduce(0) { $0 + $1.fileSize }
    }

    private let trashRepository: any TrashRepositoryProtocol
    private let confirmDeletionUseCase: ConfirmDeletionUseCase
    private let photoRepository: any PhotoRepositoryProtocol
    private let analyticsService: any AnalyticsServiceProtocol

    init(
        trashRepository: any TrashRepositoryProtocol,
        confirmDeletionUseCase: ConfirmDeletionUseCase,
        photoRepository: any PhotoRepositoryProtocol,
        analyticsService: any AnalyticsServiceProtocol
    ) {
        self.trashRepository = trashRepository
        self.confirmDeletionUseCase = confirmDeletionUseCase
        self.photoRepository = photoRepository
        self.analyticsService = analyticsService
    }

    func loadTrashItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            trashItems = try await trashRepository.getTrashItems()
            await loadThumbnails()
        } catch {
            trashItems = []
        }
    }

    private func loadThumbnails() async {
        let size = AppConstants.Photo.thumbnailSize
        for item in trashItems {
            if let image = await photoRepository.requestThumbnail(for: item.photoId, size: size) {
                thumbnails[item.photoId] = image
            }
        }
    }

    // MARK: - Selection

    func toggleSelection(id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    func selectAll() {
        if allSelected {
            selectedIds.removeAll()
        } else {
            selectedIds = Set(trashItems.map(\.id))
        }
    }

    // MARK: - Restore

    func restoreSelected() async {
        let count = selectedIds.count
        for id in selectedIds {
            try? await trashRepository.restoreFromTrash(id: id)
        }
        selectedIds.removeAll()
        await loadTrashItems()

        let event = AnalyticsEvent.trashRestored(count: count)
        analyticsService.logEvent(event.name, parameters: event.parameters)
    }

    // MARK: - Delete

    func deleteSelected() async {
        guard hasSelection else { return }
        let count = selectedIds.count
        isDeleting = true
        defer { isDeleting = false }

        do {
            deletionResult = try await confirmDeletionUseCase.executeSelected(ids: selectedIds)
            selectedIds.removeAll()
            await loadTrashItems()

            let event = AnalyticsEvent.deletionConfirmed(count: count)
            analyticsService.logEvent(event.name, parameters: event.parameters)
        } catch {
            // System dialog was cancelled or failed
        }
    }

    func deleteAll() async {
        let count = trashItems.count
        isDeleting = true
        defer { isDeleting = false }

        do {
            deletionResult = try await confirmDeletionUseCase.executeAll()
            selectedIds.removeAll()
            trashItems = []
            thumbnails = [:]

            let event = AnalyticsEvent.deletionConfirmed(count: count)
            analyticsService.logEvent(event.name, parameters: event.parameters)
        } catch {
            // System dialog was cancelled or failed
        }
    }

    func clearDeletionResult() {
        deletionResult = nil
    }
}
