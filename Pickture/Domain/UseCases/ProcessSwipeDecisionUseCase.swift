import Foundation

final class ProcessSwipeDecisionUseCase: Sendable {
    private let sessionRepository: any CleaningSessionRepositoryProtocol
    private let trashRepository: any TrashRepositoryProtocol

    init(
        sessionRepository: any CleaningSessionRepositoryProtocol,
        trashRepository: any TrashRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.trashRepository = trashRepository
    }

    func execute(
        photo: Photo,
        decision: Decision,
        session: CleaningSession
    ) async throws -> CleaningSession {
        // Record the decision
        let cleaningDecision = CleaningDecision(
            photoId: photo.id,
            sessionId: session.id,
            decision: decision
        )
        try await sessionRepository.recordDecision(cleaningDecision)

        // Update session counters
        var updatedSession = session
        updatedSession.totalReviewed += 1
        updatedSession.lastPhotoIndex += 1

        switch decision {
        case .delete:
            updatedSession.totalDeleted += 1
            updatedSession.freedBytes += photo.fileSize
            _ = try await trashRepository.addToTrash(photoId: photo.id, fileSize: photo.fileSize)
        case .keep:
            updatedSession.totalKept += 1
        }

        try await sessionRepository.updateSession(updatedSession)
        return updatedSession
    }
}
