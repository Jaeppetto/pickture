import Foundation

protocol CleaningSessionRepositoryProtocol: Sendable {
    func createSession(filter: CleaningFilter?) async throws -> CleaningSession
    func getActiveSession() async throws -> CleaningSession?
    func updateSession(_ session: CleaningSession) async throws
    func completeSession(id: String) async throws -> CleaningSession
    func recordDecision(_ decision: CleaningDecision) async throws
    func getDecisions(forSession sessionId: String) async throws -> [CleaningDecision]
    func saveFilterIndex(_ index: Int, forFilter filter: CleaningFilter?) async
    func loadFilterIndex(forFilter filter: CleaningFilter?) async -> Int?
    func clearFilterIndex(forFilter filter: CleaningFilter?) async
}
