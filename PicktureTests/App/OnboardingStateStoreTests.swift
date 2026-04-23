import Foundation
import Testing

@testable import Pickture

@Suite("OnboardingStateStore Tests")
struct OnboardingStateStoreTests {
    @Test("defaults to incomplete when key is missing")
    func defaultsToIncomplete() throws {
        let defaults = try makeDefaults(named: "defaults")
        let store = OnboardingStateStore(defaults: defaults)

        #expect(store.hasCompletedOnboarding == false)
    }

    @Test("persists completed state")
    func persistsCompletedState() throws {
        let defaults = try makeDefaults(named: "persists")
        let store = OnboardingStateStore(defaults: defaults)

        store.markCompleted()
        let reloaded = OnboardingStateStore(defaults: defaults)

        #expect(reloaded.hasCompletedOnboarding == true)
    }

    private func makeDefaults(named name: String) throws -> UserDefaults {
        let suiteName = "OnboardingStateStoreTests.\(name)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
