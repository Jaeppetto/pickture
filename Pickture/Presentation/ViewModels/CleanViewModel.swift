import Foundation
import UIKit

enum CleanScreenState: Equatable {
    case idle
    case filterSelection
    case cleaning
    case summary(CleaningSession)
}

@Observable
@MainActor
final class CleanViewModel {
    // MARK: - State

    private(set) var screenState: CleanScreenState = .idle
    private(set) var currentSession: CleaningSession?
    private(set) var photos: [Photo] = []
    private(set) var currentIndex: Int = 0
    private(set) var totalPhotoCount: Int = 0
    private(set) var thumbnails: [String: UIImage] = [:]
    private(set) var isLoadingPhotos = false
    private(set) var selectedMetadataPhoto: Photo?
    private(set) var hasMorePhotos = true

    // MARK: - Offset

    private var initialOffset: Int = 0

    // MARK: - Undo

    private var undoStack: [(Photo, Decision)] = []
    var canUndo: Bool { !undoStack.isEmpty }
    private let maxUndoCount = 10

    // MARK: - Dependencies

    private let photoRepository: any PhotoRepositoryProtocol
    private let startSessionUseCase: StartCleaningSessionUseCase
    private let processDecisionUseCase: ProcessSwipeDecisionUseCase
    private let completeSessionUseCase: CompleteSessionUseCase
    private let sessionRepository: any CleaningSessionRepositoryProtocol

    private let pageSize = AppConstants.Photo.pageSize
    private let prefetchThreshold = 10
    private let cacheAheadCount = 5
    private let cacheBehindCount = 2

    init(
        photoRepository: any PhotoRepositoryProtocol,
        startSessionUseCase: StartCleaningSessionUseCase,
        processDecisionUseCase: ProcessSwipeDecisionUseCase,
        completeSessionUseCase: CompleteSessionUseCase,
        sessionRepository: any CleaningSessionRepositoryProtocol
    ) {
        self.photoRepository = photoRepository
        self.startSessionUseCase = startSessionUseCase
        self.processDecisionUseCase = processDecisionUseCase
        self.completeSessionUseCase = completeSessionUseCase
        self.sessionRepository = sessionRepository
    }

    // MARK: - Session Lifecycle

    func checkForActiveSession() async {
        do {
            if let session = try await sessionRepository.getActiveSession() {
                currentSession = session
                currentIndex = session.lastPhotoIndex
                await startCleaning(filter: session.filter, resuming: true)
            }
        } catch {
            // No active session — stay idle
        }
    }

    func showFilterSelection() {
        screenState = .filterSelection
    }

    func startNewSession(filter: CleaningFilter? = nil, startOffset: Int = 0) async {
        await startCleaning(filter: filter, resuming: false, startOffset: startOffset)
    }

    func applyPendingFilter(_ filter: CleaningFilter?) async {
        await startCleaning(filter: filter, resuming: false)
    }

    private func startCleaning(filter: CleaningFilter?, resuming: Bool, startOffset: Int = 0) async {
        do {
            if !resuming {
                currentSession = try await startSessionUseCase.execute(filter: filter)
                currentIndex = 0
                initialOffset = startOffset
                photos = []
                thumbnails = [:]
                undoStack = []
                hasMorePhotos = true
            }

            let fullCount = try await photoRepository.fetchPhotoCount(filter: filter)
            totalPhotoCount = max(0, fullCount - initialOffset)
            await loadNextPage(filter: filter)
            screenState = .cleaning
        } catch {
            screenState = .idle
        }
    }

    func completeSession() async {
        guard let session = currentSession else { return }
        do {
            let completed = try await completeSessionUseCase.execute(sessionId: session.id)
            currentSession = completed
            screenState = .summary(completed)
            HapticManager.sessionComplete()
            await stopAllCaching()
        } catch {
            // Fallback to idle
            screenState = .idle
        }
    }

    func returnToIdle() {
        screenState = .idle
        currentSession = nil
        photos = []
        thumbnails = [:]
        currentIndex = 0
        undoStack = []
    }

    // MARK: - Swipe Decision

    func processSwipe(_ decision: Decision) async {
        guard currentIndex < photos.count, let session = currentSession else { return }
        let photo = photos[currentIndex]

        // Haptic feedback
        switch decision {
        case .delete: HapticManager.swipeDelete()
        case .keep: HapticManager.swipeKeep()
        case .favorite: HapticManager.swipeFavorite()
        }

        // Record undo
        if undoStack.count >= maxUndoCount {
            undoStack.removeFirst()
        }
        undoStack.append((photo, decision))

        do {
            currentSession = try await processDecisionUseCase.execute(
                photo: photo,
                decision: decision,
                session: session
            )
            currentIndex += 1

            // Update caching window
            await updateCachingWindow()

            // Prefetch next page if needed
            let remainingInPage = photos.count - currentIndex
            if remainingInPage <= prefetchThreshold && hasMorePhotos {
                await loadNextPage(filter: currentSession?.filter)
            }

            // Check if we've reviewed all photos
            if currentIndex >= photos.count && !hasMorePhotos {
                await completeSession()
            }
        } catch {
            // Revert undo stack on failure
            undoStack.removeLast()
        }
    }

    func undoLastDecision() async {
        guard let (_, _) = undoStack.last, currentIndex > 0 else { return }
        undoStack.removeLast()
        currentIndex -= 1
        HapticManager.undo()

        // Update session counters (simplified: reload from repository)
        if let session = currentSession {
            currentSession = try? await sessionRepository.getActiveSession()
            if currentSession == nil { currentSession = session }
        }
    }

    // MARK: - Button Actions (for accessibility buttons below card)

    func deleteCurrentPhoto() async {
        await processSwipe(.delete)
    }

    func keepCurrentPhoto() async {
        await processSwipe(.keep)
    }

    func favoriteCurrentPhoto() async {
        await processSwipe(.favorite)
    }

    // MARK: - Metadata

    func showMetadata(for photo: Photo) {
        selectedMetadataPhoto = photo
    }

    func hideMetadata() {
        selectedMetadataPhoto = nil
    }

    // MARK: - Photo Loading

    private func loadNextPage(filter: CleaningFilter?) async {
        guard !isLoadingPhotos, hasMorePhotos else { return }
        isLoadingPhotos = true
        defer { isLoadingPhotos = false }

        do {
            let offset = initialOffset + photos.count
            let newPhotos = try await photoRepository.fetchPhotos(
                offset: offset,
                limit: pageSize,
                filter: filter
            )

            if newPhotos.count < pageSize {
                hasMorePhotos = false
            }

            photos.append(contentsOf: newPhotos)
            await loadThumbnails(for: newPhotos)
        } catch {
            hasMorePhotos = false
        }
    }

    private func loadThumbnails(for newPhotos: [Photo]) async {
        let size = AppConstants.Photo.previewSize
        // Start caching for new photos
        let ids = newPhotos.map(\.id)
        await photoRepository.startCachingThumbnails(for: ids, targetSize: size)

        // Load thumbnails for upcoming photos
        for photo in newPhotos {
            if let image = await photoRepository.requestThumbnail(for: photo.id, size: size) {
                thumbnails[photo.id] = image
            }
        }
    }

    private func updateCachingWindow() async {
        let size = AppConstants.Photo.previewSize

        // Cache ahead
        let aheadStart = currentIndex + 1
        let aheadEnd = min(currentIndex + 1 + cacheAheadCount, photos.count)
        if aheadStart < aheadEnd {
            let aheadIds = (aheadStart..<aheadEnd).map { photos[$0].id }
            await photoRepository.startCachingThumbnails(for: aheadIds, targetSize: size)

            // Load thumbnails that we haven't loaded yet
            for index in aheadStart..<aheadEnd {
                let photo = photos[index]
                if thumbnails[photo.id] == nil {
                    if let image = await photoRepository.requestThumbnail(for: photo.id, size: size) {
                        thumbnails[photo.id] = image
                    }
                }
            }
        }

        // Stop caching behind (keep recent few for undo)
        let behindEnd = max(0, currentIndex - cacheBehindCount)
        if behindEnd > 0 {
            let oldIds = (0..<behindEnd).map { photos[$0].id }
            await photoRepository.stopCachingThumbnails(for: oldIds, targetSize: size)
            // Free memory for old thumbnails
            for id in oldIds {
                thumbnails.removeValue(forKey: id)
            }
        }
    }

    private func stopAllCaching() async {
        let size = AppConstants.Photo.previewSize
        let allIds = photos.map(\.id)
        await photoRepository.stopCachingThumbnails(for: allIds, targetSize: size)
    }
}
