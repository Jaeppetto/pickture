import Foundation

final class CleaningSessionRepository: CleaningSessionRepositoryProtocol, @unchecked Sendable {
    private let localStorage: LocalStorageDataSource

    init(localStorage: LocalStorageDataSource) {
        self.localStorage = localStorage
    }

    func createSession(filter: CleaningFilter?) async throws -> CleaningSession {
        let session = CleaningSession(filter: filter)
        try await localStorage.saveSession(session)
        await localStorage.saveActiveSessionId(session.id)
        return session
    }

    func getActiveSession() async throws -> CleaningSession? {
        guard let activeId = await localStorage.loadActiveSessionId() else { return nil }
        guard let session = await localStorage.loadSession(id: activeId) else {
            await localStorage.saveActiveSessionId(nil)
            return nil
        }
        if session.status == .completed {
            await localStorage.saveActiveSessionId(nil)
            return nil
        }
        return session
    }

    func updateSession(_ session: CleaningSession) async throws {
        try await localStorage.saveSession(session)
    }

    func completeSession(id: String) async throws -> CleaningSession {
        guard var session = await localStorage.loadSession(id: id) else {
            throw RepositoryError.notFound
        }
        session.status = .completed
        session.endedAt = .now
        try await localStorage.saveSession(session)
        await localStorage.saveActiveSessionId(nil)
        return session
    }

    func recordDecision(_ decision: CleaningDecision) async throws {
        try await localStorage.saveDecision(decision)
    }

    func getDecisions(forSession sessionId: String) async throws -> [CleaningDecision] {
        await localStorage.loadDecisions(forSession: sessionId)
    }
}

enum RepositoryError: Error, LocalizedError {
    case notFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .notFound: "Requested item was not found."
        case .saveFailed: "Failed to save data."
        }
    }
}
