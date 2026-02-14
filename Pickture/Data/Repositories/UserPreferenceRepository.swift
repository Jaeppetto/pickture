import Foundation

final class UserPreferenceRepository: UserPreferenceRepositoryProtocol, @unchecked Sendable {
    private let localStorage: LocalStorageDataSource

    init(localStorage: LocalStorageDataSource) {
        self.localStorage = localStorage
    }

    func getPreferences() async -> UserPreference {
        await localStorage.loadPreferences()
    }

    func updatePreferences(_ preferences: UserPreference) async throws {
        try await localStorage.savePreferences(preferences)
    }

    func updateThemeMode(_ mode: ThemeMode) async throws {
        var prefs = await getPreferences()
        prefs.themeMode = mode
        try await updatePreferences(prefs)
    }

    func updateLocale(_ locale: String) async throws {
        var prefs = await getPreferences()
        prefs.locale = locale
        try await updatePreferences(prefs)
    }

    func updateDailyGoal(_ goal: Int) async throws {
        var prefs = await getPreferences()
        prefs.dailyGoal = goal
        try await updatePreferences(prefs)
    }

    func updateHapticEnabled(_ enabled: Bool) async throws {
        var prefs = await getPreferences()
        prefs.hapticEnabled = enabled
        try await updatePreferences(prefs)
    }
}
