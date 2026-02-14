import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var storageInfo = StorageInfo()
    private(set) var insights: [StorageInsight] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false

    private let analyzeStorageUseCase: AnalyzeStorageUseCase
    private let navigationCoordinator: NavigationCoordinator

    init(
        analyzeStorageUseCase: AnalyzeStorageUseCase,
        navigationCoordinator: NavigationCoordinator
    ) {
        self.analyzeStorageUseCase = analyzeStorageUseCase
        self.navigationCoordinator = navigationCoordinator
    }

    func loadStorageInfo() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await analyzeStorageUseCase.execute()
            storageInfo = result.storageInfo
            insights = result.insights
            hasLoaded = true
        } catch {
            // Silently fail — UI shows empty state
        }
    }

    func startCleaning(with filter: CleaningFilter? = nil) {
        navigationCoordinator.navigateToClean(with: filter)
    }
}
