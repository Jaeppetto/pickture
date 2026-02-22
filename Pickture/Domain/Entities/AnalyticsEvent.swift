import Foundation

enum AnalyticsEvent {
    // Cleaning
    case sessionStarted(filter: String, photoCount: Int)
    case swipeDecision(decision: String, photoIndex: Int)
    case undoDecision
    case sessionCompleted(kept: Int, deleted: Int, duration: TimeInterval)

    // Deletion
    case deletionConfirmed(count: Int)
    case trashRestored(count: Int)

    // Navigation
    case screenViewed(name: String)
    case tabSelected(tab: String)

    // Settings
    case settingChanged(key: String, value: String)

    var name: String {
        switch self {
        case .sessionStarted: "session_started"
        case .swipeDecision: "swipe_decision"
        case .undoDecision: "undo_decision"
        case .sessionCompleted: "session_completed"
        case .deletionConfirmed: "deletion_confirmed"
        case .trashRestored: "trash_restored"
        case .screenViewed: "screen_viewed"
        case .tabSelected: "tab_selected"
        case .settingChanged: "setting_changed"
        }
    }

    var parameters: [String: any Sendable]? {
        switch self {
        case let .sessionStarted(filter, photoCount):
            ["filter": filter, "photo_count": photoCount]
        case let .swipeDecision(decision, photoIndex):
            ["decision": decision, "photo_index": photoIndex]
        case .undoDecision:
            nil
        case let .sessionCompleted(kept, deleted, duration):
            ["kept": kept, "deleted": deleted, "duration_seconds": Int(duration)]
        case let .deletionConfirmed(count):
            ["count": count]
        case let .trashRestored(count):
            ["count": count]
        case let .screenViewed(name):
            ["screen_name": name]
        case let .tabSelected(tab):
            ["tab": tab]
        case let .settingChanged(key, value):
            ["key": key, "value": value]
        }
    }
}
