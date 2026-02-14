import Foundation

final class CompleteSessionUseCase: Sendable {
    private let sessionRepository: any CleaningSessionRepositoryProtocol

    init(sessionRepository: any CleaningSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    func execute(sessionId: String) async throws -> CleaningSession {
        try await sessionRepository.completeSession(id: sessionId)
    }
}
