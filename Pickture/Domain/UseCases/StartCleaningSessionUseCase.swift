import Foundation

final class StartCleaningSessionUseCase: Sendable {
    private let sessionRepository: any CleaningSessionRepositoryProtocol

    init(sessionRepository: any CleaningSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    func execute(filter: CleaningFilter?) async throws -> CleaningSession {
        // Check for existing active session
        if let existing = try await sessionRepository.getActiveSession() {
            return existing
        }
        return try await sessionRepository.createSession(filter: filter)
    }
}
