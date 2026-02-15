import Foundation

@Observable
@MainActor
final class SettingsViewModel {
    private(set) var preferences: UserPreference = .default

    private let preferenceRepository: any UserPreferenceRepositoryProtocol

    init(preferenceRepository: any UserPreferenceRepositoryProtocol) {
        self.preferenceRepository = preferenceRepository
    }

    func loadPreferences() async {
        preferences = await preferenceRepository.getPreferences()
    }

    func updateThemeMode(_ mode: ThemeMode) async {
        preferences.themeMode = mode
        try? await preferenceRepository.updateThemeMode(mode)
    }

    func updateHapticEnabled(_ enabled: Bool) async {
        preferences.hapticEnabled = enabled
        try? await preferenceRepository.updateHapticEnabled(enabled)
    }
}
