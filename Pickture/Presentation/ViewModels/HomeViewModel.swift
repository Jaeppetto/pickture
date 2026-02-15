import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var storageInfo = StorageInfo()
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var trashItemCount: Int = 0

    private let analyzeStorageUseCase: AnalyzeStorageUseCase
    private let navigationCoordinator: NavigationCoordinator
    private let trashRepository: any TrashRepositoryProtocol

    init(
        analyzeStorageUseCase: AnalyzeStorageUseCase,
        navigationCoordinator: NavigationCoordinator,
        trashRepository: any TrashRepositoryProtocol
    ) {
        self.analyzeStorageUseCase = analyzeStorageUseCase
        self.navigationCoordinator = navigationCoordinator
        self.trashRepository = trashRepository
    }

    func loadStorageInfo() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await analyzeStorageUseCase.execute()
            storageInfo = result.storageInfo
            hasLoaded = true
        } catch {
            // Silently fail — UI shows empty state
        }

        await loadTrashCount()
    }

    func loadTrashCount() async {
        do {
            let items = try await trashRepository.getTrashItems()
            trashItemCount = items.count
        } catch {
            trashItemCount = 0
        }
    }

    func startCleaning(with filter: CleaningFilter? = nil) {
        navigationCoordinator.navigateToClean(with: filter)
    }
}
