import Foundation

public struct CleaningDecision: Sendable, Equatable, Codable {
    public let photoId: String
    public let sessionId: String
    public let decision: Decision
    public let decidedAt: Date

    public init(
        photoId: String,
        sessionId: String,
        decision: Decision,
        decidedAt: Date = .now
    ) {
        self.photoId = photoId
        self.sessionId = sessionId
        self.decision = decision
        self.decidedAt = decidedAt
    }
}

public enum Decision: String, Sendable, Equatable, CaseIterable, Codable {
    case delete
    case keep
}
