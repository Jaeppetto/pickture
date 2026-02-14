import Foundation

actor LocalStorageDataSource {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private enum Keys {
        static let userPreferences = "user_preferences"
        static let activeSessionId = "active_session_id"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func savePreferences(_ preferences: UserPreference) throws {
        let data = try encoder.encode(preferences)
        defaults.set(data, forKey: Keys.userPreferences)
    }

    func loadPreferences() -> UserPreference {
        guard let data = defaults.data(forKey: Keys.userPreferences),
              let preferences = try? decoder.decode(UserPreference.self, from: data) else {
            return .default
        }
        return preferences
    }

    func saveActiveSessionId(_ id: String?) {
        defaults.set(id, forKey: Keys.activeSessionId)
    }

    func loadActiveSessionId() -> String? {
        defaults.string(forKey: Keys.activeSessionId)
    }
}
