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

    func updateHapticEnabled(_ enabled: Bool) async {
        preferences.hapticEnabled = enabled
        try? await preferenceRepository.updateHapticEnabled(enabled)
    }

    func updateLocale(_ locale: String) async {
        preferences.locale = locale
        try? await preferenceRepository.updateLocale(locale)
    }
}
