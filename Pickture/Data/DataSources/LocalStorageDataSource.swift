import Foundation

actor LocalStorageDataSource {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private enum Keys {
        static let userPreferences = "user_preferences"
        static let activeSessionId = "active_session_id"
        static let sessions = "cleaning_sessions"
        static let decisions = "cleaning_decisions"
        static let trashItems = "trash_items"
        static let filterSessionIndices = "filter_session_indices"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - User Preferences

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

    // MARK: - Active Session ID

    func saveActiveSessionId(_ id: String?) {
        defaults.set(id, forKey: Keys.activeSessionId)
    }

    func loadActiveSessionId() -> String? {
        defaults.string(forKey: Keys.activeSessionId)
    }

    // MARK: - Sessions

    func saveSession(_ session: CleaningSession) throws {
        var sessions = loadAllSessions()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: Keys.sessions)
    }

    func loadSession(id: String) -> CleaningSession? {
        loadAllSessions().first { $0.id == id }
    }

    func loadAllSessions() -> [CleaningSession] {
        guard let data = defaults.data(forKey: Keys.sessions),
              let sessions = try? decoder.decode([CleaningSession].self, from: data) else {
            return []
        }
        return sessions
    }

    func deleteSession(id: String) throws {
        var sessions = loadAllSessions()
        sessions.removeAll { $0.id == id }
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: Keys.sessions)
    }

    // MARK: - Decisions

    func saveDecision(_ decision: CleaningDecision) throws {
        var decisions = loadAllDecisions()
        decisions.append(decision)
        let data = try encoder.encode(decisions)
        defaults.set(data, forKey: Keys.decisions)
    }

    func loadDecisions(forSession sessionId: String) -> [CleaningDecision] {
        loadAllDecisions().filter { $0.sessionId == sessionId }
    }

    private func loadAllDecisions() -> [CleaningDecision] {
        guard let data = defaults.data(forKey: Keys.decisions),
              let decisions = try? decoder.decode([CleaningDecision].self, from: data) else {
            return []
        }
        return decisions
    }

    // MARK: - Trash Items

    func saveTrashItem(_ item: TrashItem) throws {
        var items = loadTrashItems()
        items.append(item)
        let data = try encoder.encode(items)
        defaults.set(data, forKey: Keys.trashItems)
    }

    func loadTrashItems() -> [TrashItem] {
        guard let data = defaults.data(forKey: Keys.trashItems),
              let items = try? decoder.decode([TrashItem].self, from: data) else {
            return []
        }
        return items
    }

    func removeTrashItem(id: String) throws {
        var items = loadTrashItems()
        items.removeAll { $0.id == id }
        let data = try encoder.encode(items)
        defaults.set(data, forKey: Keys.trashItems)
    }

    func clearAllTrashItems() {
        defaults.removeObject(forKey: Keys.trashItems)
    }

    // MARK: - Filter Session Indices

    func saveFilterIndex(_ index: Int, forKey key: String) {
        var indices = loadAllFilterIndices()
        indices[key] = index
        if let data = try? encoder.encode(indices) {
            defaults.set(data, forKey: Keys.filterSessionIndices)
        }
    }

    func loadFilterIndex(forKey key: String) -> Int? {
        loadAllFilterIndices()[key]
    }

    func clearFilterIndex(forKey key: String) {
        var indices = loadAllFilterIndices()
        indices.removeValue(forKey: key)
        if let data = try? encoder.encode(indices) {
            defaults.set(data, forKey: Keys.filterSessionIndices)
        }
    }

    private func loadAllFilterIndices() -> [String: Int] {
        guard let data = defaults.data(forKey: Keys.filterSessionIndices),
              let indices = try? decoder.decode([String: Int].self, from: data) else {
            return [:]
        }
        return indices
    }
}
