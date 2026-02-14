import Foundation

protocol CleaningSessionRepositoryProtocol: Sendable {
    func createSession(filter: CleaningFilter?) async throws -> CleaningSession
    func getActiveSession() async throws -> CleaningSession?
    func updateSession(_ session: CleaningSession) async throws
    func completeSession(id: String) async throws -> CleaningSession
    func recordDecision(_ decision: CleaningDecision) async throws
    func getDecisions(forSession sessionId: String) async throws -> [CleaningDecision]
}
