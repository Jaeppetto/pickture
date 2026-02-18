import Foundation

@MainActor
final class AppContainer {
    // MARK: - Data Sources

    private let photoLibraryDataSource = PhotoLibraryDataSource()
    private let localStorageDataSource = LocalStorageDataSource()

    // MARK: - Repositories

    private(set) lazy var photoRepository: any PhotoRepositoryProtocol = PhotoRepository(
        dataSource: photoLibraryDataSource
    )

    private(set) lazy var cleaningSessionRepository: any CleaningSessionRepositoryProtocol = CleaningSessionRepository(
        localStorage: localStorageDataSource
    )

    private(set) lazy var trashRepository: any TrashRepositoryProtocol = TrashRepository(
        localStorage: localStorageDataSource,
        photoDataSource: photoLibraryDataSource
    )

    private(set) lazy var userPreferenceRepository: any UserPreferenceRepositoryProtocol = UserPreferenceRepository(
        localStorage: localStorageDataSource
    )

    private(set) lazy var storageAnalysisRepository: any StorageAnalysisRepositoryProtocol = StorageAnalysisRepository(
        photoDataSource: photoLibraryDataSource
    )

    // MARK: - Theme

    let theme = AppTheme()

    // MARK: - Navigation

    let navigationCoordinator = NavigationCoordinator()

    // MARK: - Use Case Factories

    func makeAnalyzeStorageUseCase() -> AnalyzeStorageUseCase {
        AnalyzeStorageUseCase(storageRepository: storageAnalysisRepository)
    }

    func makeStartCleaningSessionUseCase() -> StartCleaningSessionUseCase {
        StartCleaningSessionUseCase(sessionRepository: cleaningSessionRepository)
    }

    func makeProcessSwipeDecisionUseCase() -> ProcessSwipeDecisionUseCase {
        ProcessSwipeDecisionUseCase(
            sessionRepository: cleaningSessionRepository,
            trashRepository: trashRepository
        )
    }

    func makeCompleteSessionUseCase() -> CompleteSessionUseCase {
        CompleteSessionUseCase(sessionRepository: cleaningSessionRepository)
    }

    func makeConfirmDeletionUseCase() -> ConfirmDeletionUseCase {
        ConfirmDeletionUseCase(trashRepository: trashRepository)
    }

    // MARK: - Shared ViewModels

    private(set) lazy var photoPermissionViewModel = PhotoPermissionViewModel(
        photoRepository: photoRepository
    )

    // MARK: - ViewModel Factories

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            analyzeStorageUseCase: makeAnalyzeStorageUseCase(),
            navigationCoordinator: navigationCoordinator,
            trashRepository: trashRepository
        )
    }

    func makeCleanViewModel() -> CleanViewModel {
        CleanViewModel(
            photoRepository: photoRepository,
            startSessionUseCase: makeStartCleaningSessionUseCase(),
            processDecisionUseCase: makeProcessSwipeDecisionUseCase(),
            completeSessionUseCase: makeCompleteSessionUseCase(),
            sessionRepository: cleaningSessionRepository,
            trashRepository: trashRepository
        )
    }

    func makeDeletionQueueViewModel() -> DeletionQueueViewModel {
        DeletionQueueViewModel(
            trashRepository: trashRepository,
            confirmDeletionUseCase: makeConfirmDeletionUseCase(),
            photoRepository: photoRepository
        )
    }

    private(set) lazy var settingsViewModel = SettingsViewModel(
        preferenceRepository: userPreferenceRepository
    )
}
