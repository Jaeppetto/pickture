import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var storageInfo = StorageInfo()
    private(set) var isLoading = false

    private let storageRepository: any StorageAnalysisRepositoryProtocol

    init(storageRepository: any StorageAnalysisRepositoryProtocol) {
        self.storageRepository = storageRepository
    }

    func loadStorageInfo() async {
        isLoading = true
        defer { isLoading = false }

        do {
            storageInfo = try await storageRepository.analyzeStorage()
        } catch {
            // TODO: Error handling in Phase 2
        }
    }
}
