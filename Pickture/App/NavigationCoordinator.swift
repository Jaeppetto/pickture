import Foundation

@Observable
@MainActor
final class NavigationCoordinator {
    var selectedTab: AppTab = .home
    var pendingCleanFilter: CleaningFilter?

    func navigateToClean(with filter: CleaningFilter? = nil) {
        pendingCleanFilter = filter
        selectedTab = .clean
    }

    func navigateToHome() {
        selectedTab = .home
    }

    func consumePendingFilter() -> CleaningFilter? {
        defer { pendingCleanFilter = nil }
        return pendingCleanFilter
    }
}
