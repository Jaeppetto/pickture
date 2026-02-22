import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var storageInfo = StorageInfo()
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var trashItemCount: Int = 0
    private(set) var lastSession: CleaningSession?
    private(set) var expiringItems: [TrashItem] = []

    var expiringItemCount: Int { expiringItems.count }
    var expiringItemsTotalBytes: Int64 { expiringItems.reduce(0) { $0 + $1.fileSize } }

    private let analyzeStorageUseCase: AnalyzeStorageUseCase
    private let navigationCoordinator: NavigationCoordinator
    private let trashRepository: any TrashRepositoryProtocol
    private let cleaningSessionRepository: any CleaningSessionRepositoryProtocol
    private let analyticsService: any AnalyticsServiceProtocol

    init(
        analyzeStorageUseCase: AnalyzeStorageUseCase,
        navigationCoordinator: NavigationCoordinator,
        trashRepository: any TrashRepositoryProtocol,
        cleaningSessionRepository: any CleaningSessionRepositoryProtocol,
        analyticsService: any AnalyticsServiceProtocol
    ) {
        self.analyzeStorageUseCase = analyzeStorageUseCase
        self.navigationCoordinator = navigationCoordinator
        self.trashRepository = trashRepository
        self.cleaningSessionRepository = cleaningSessionRepository
        self.analyticsService = analyticsService
    }

    func loadStorageInfo() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let event = AnalyticsEvent.screenViewed(name: "home")
        analyticsService.logEvent(event.name, parameters: event.parameters)

        do {
            let result = try await analyzeStorageUseCase.execute()
            storageInfo = result.storageInfo
            hasLoaded = true
        } catch {
            // Silently fail — UI shows empty state
        }

        await loadTrashCount()
        await loadLastSession()
    }

    func loadTrashCount() async {
        do {
            let items = try await trashRepository.getTrashItems()
            trashItemCount = items.count
            expiringItems = try await trashRepository.getNearExpiringItems(withinDays: 3)
        } catch {
            trashItemCount = 0
            expiringItems = []
        }
    }

    func loadLastSession() async {
        do {
            lastSession = try await cleaningSessionRepository.getLastCompletedSession()
        } catch {
            lastSession = nil
        }
    }

    func startCleaning(with filter: CleaningFilter? = nil) {
        let event = AnalyticsEvent.tabSelected(tab: "clean")
        analyticsService.logEvent(event.name, parameters: event.parameters)

        navigationCoordinator.navigateToClean(with: filter)
    }
}
