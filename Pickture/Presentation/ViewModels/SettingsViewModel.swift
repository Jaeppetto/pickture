import Foundation

@Observable
@MainActor
final class SettingsViewModel {
    private(set) var preferences: UserPreference = .default

    private let preferenceRepository: any UserPreferenceRepositoryProtocol
    private let analyticsService: any AnalyticsServiceProtocol

    init(
        preferenceRepository: any UserPreferenceRepositoryProtocol,
        analyticsService: any AnalyticsServiceProtocol
    ) {
        self.preferenceRepository = preferenceRepository
        self.analyticsService = analyticsService
    }

    func loadPreferences() async {
        preferences = await preferenceRepository.getPreferences()
    }

    func updateHapticEnabled(_ enabled: Bool) async {
        preferences.hapticEnabled = enabled
        try? await preferenceRepository.updateHapticEnabled(enabled)

        let event = AnalyticsEvent.settingChanged(key: "haptic_enabled", value: String(enabled))
        analyticsService.logEvent(event.name, parameters: event.parameters)
    }

    func updateLocale(_ locale: String) async {
        preferences.locale = locale
        try? await preferenceRepository.updateLocale(locale)

        let event = AnalyticsEvent.settingChanged(key: "locale", value: locale)
        analyticsService.logEvent(event.name, parameters: event.parameters)
    }
}
