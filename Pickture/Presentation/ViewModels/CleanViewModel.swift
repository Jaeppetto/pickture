import Foundation

@Observable
@MainActor
final class CleanViewModel {
    private(set) var currentSession: CleaningSession?
    private(set) var isSessionActive = false

    private let sessionRepository: any CleaningSessionRepositoryProtocol
    private let photoRepository: any PhotoRepositoryProtocol

    init(
        sessionRepository: any CleaningSessionRepositoryProtocol,
        photoRepository: any PhotoRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.photoRepository = photoRepository
    }

    func checkForActiveSession() async {
        do {
            currentSession = try await sessionRepository.getActiveSession()
            isSessionActive = currentSession != nil
        } catch {
            // TODO: Error handling in Phase 2
        }
    }

    func startNewSession(filter: CleaningFilter? = nil) async {
        do {
            currentSession = try await sessionRepository.createSession(filter: filter)
            isSessionActive = true
        } catch {
            // TODO: Error handling in Phase 2
        }
    }
}
