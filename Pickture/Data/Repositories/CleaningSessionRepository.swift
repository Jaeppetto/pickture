import Foundation

final class CleaningSessionRepository: CleaningSessionRepositoryProtocol, @unchecked Sendable {
    private let localStorage: LocalStorageDataSource

    init(localStorage: LocalStorageDataSource) {
        self.localStorage = localStorage
    }

    func createSession(filter: CleaningFilter?) async throws -> CleaningSession {
        // Stub
        CleaningSession(filter: filter)
    }

    func getActiveSession() async throws -> CleaningSession? {
        // Stub
        nil
    }

    func updateSession(_ session: CleaningSession) async throws {
        // Stub
    }

    func completeSession(id: String) async throws -> CleaningSession {
        // Stub
        CleaningSession(id: id, status: .completed, endedAt: .now)
    }

    func recordDecision(_ decision: CleaningDecision) async throws {
        // Stub
    }

    func getDecisions(forSession sessionId: String) async throws -> [CleaningDecision] {
        // Stub
        []
    }
}
