import Foundation

protocol UserPreferenceRepositoryProtocol: Sendable {
    func getPreferences() async -> UserPreference
    func updatePreferences(_ preferences: UserPreference) async throws
    func updateThemeMode(_ mode: ThemeMode) async throws
    func updateLocale(_ locale: String) async throws
    func updateDailyGoal(_ goal: Int) async throws
    func updateHapticEnabled(_ enabled: Bool) async throws
}
