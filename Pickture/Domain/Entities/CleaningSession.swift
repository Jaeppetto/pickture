import Foundation

public struct CleaningSession: Sendable, Equatable, Identifiable {
    public let id: String
    public var startedAt: Date
    public var endedAt: Date?
    public var status: SessionStatus
    public var lastPhotoIndex: Int
    public var totalReviewed: Int
    public var totalDeleted: Int
    public var totalKept: Int
    public var totalFavorited: Int
    public var freedBytes: Int64
    public var filter: CleaningFilter?

    public init(
        id: String = UUID().uuidString,
        startedAt: Date = .now,
        status: SessionStatus = .active,
        endedAt: Date? = nil,
        lastPhotoIndex: Int = 0,
        totalReviewed: Int = 0,
        totalDeleted: Int = 0,
        totalKept: Int = 0,
        totalFavorited: Int = 0,
        freedBytes: Int64 = 0,
        filter: CleaningFilter? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.status = status
        self.lastPhotoIndex = lastPhotoIndex
        self.totalReviewed = totalReviewed
        self.totalDeleted = totalDeleted
        self.totalKept = totalKept
        self.totalFavorited = totalFavorited
        self.freedBytes = freedBytes
        self.filter = filter
    }
}

public enum SessionStatus: String, Sendable, Equatable, CaseIterable {
    case active
    case paused
    case completed
}
