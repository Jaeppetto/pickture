import Foundation

final class OnboardingStateStore {
    private let defaults: UserDefaults
    private let completionKey = "onboarding_completed"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: completionKey)
    }

    func markCompleted() {
        defaults.set(true, forKey: completionKey)
    }
}
