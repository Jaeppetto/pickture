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

    private(set) lazy var trashRepository: any TrashRepositoryProtocol = TrashRepository()

    private(set) lazy var userPreferenceRepository: any UserPreferenceRepositoryProtocol = UserPreferenceRepository(
        localStorage: localStorageDataSource
    )

    private(set) lazy var storageAnalysisRepository: any StorageAnalysisRepositoryProtocol = StorageAnalysisRepository()

    // MARK: - Theme

    let theme = AppTheme()

    // MARK: - ViewModel Factories

    func makePhotoPermissionViewModel() -> PhotoPermissionViewModel {
        PhotoPermissionViewModel(photoRepository: photoRepository)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(storageRepository: storageAnalysisRepository)
    }

    func makeCleanViewModel() -> CleanViewModel {
        CleanViewModel(
            sessionRepository: cleaningSessionRepository,
            photoRepository: photoRepository
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(preferenceRepository: userPreferenceRepository)
    }
}
