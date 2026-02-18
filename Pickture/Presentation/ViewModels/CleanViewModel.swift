import Foundation
import UIKit

enum CleanScreenState: Equatable {
    case idle
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
    private(set) var hasMorePhotos = true

    // MARK: - Resume Alert

    var showResumeAlert = false
    private(set) var pendingResumeFilter: CleaningFilter?
    private(set) var pendingResumeIndex: Int = 0

    // MARK: - Offset

    private var initialOffset: Int = 0
    private var isShuffled = false

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
    private let trashRepository: any TrashRepositoryProtocol

    private let pageSize = AppConstants.Photo.pageSize
    private let prefetchThreshold = 10
    private let cacheAheadCount = 5
    private let cacheBehindCount = 2

    init(
        photoRepository: any PhotoRepositoryProtocol,
        startSessionUseCase: StartCleaningSessionUseCase,
        processDecisionUseCase: ProcessSwipeDecisionUseCase,
        completeSessionUseCase: CompleteSessionUseCase,
        sessionRepository: any CleaningSessionRepositoryProtocol,
        trashRepository: any TrashRepositoryProtocol
    ) {
        self.photoRepository = photoRepository
        self.startSessionUseCase = startSessionUseCase
        self.processDecisionUseCase = processDecisionUseCase
        self.completeSessionUseCase = completeSessionUseCase
        self.sessionRepository = sessionRepository
        self.trashRepository = trashRepository
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

    func startNewSession(filter: CleaningFilter? = nil, startOffset: Int = 0, shuffled: Bool = false) async {
        // Check for saved index if not shuffled
        if !shuffled, let savedIndex = await sessionRepository.loadFilterIndex(forFilter: filter), savedIndex > 0 {
            pendingResumeFilter = filter
            pendingResumeIndex = savedIndex
            showResumeAlert = true
            return
        }

        isShuffled = shuffled
        await startCleaning(filter: filter, resuming: false, startOffset: startOffset)
    }

    func resumeFromSavedIndex() async {
        isShuffled = false
        await startCleaning(filter: pendingResumeFilter, resuming: false, startOffset: pendingResumeIndex)
    }

    func startFresh() async {
        let filter = pendingResumeFilter
        await sessionRepository.clearFilterIndex(forFilter: filter)
        isShuffled = false
        await startCleaning(filter: filter, resuming: false)
    }

    func applyPendingFilter(_ filter: CleaningFilter?) async {
        isShuffled = false
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

            // Save filter index for resume
            await sessionRepository.saveFilterIndex(
                initialOffset + currentIndex,
                forFilter: session.filter
            )

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
        guard let (photo, decision) = undoStack.last, currentIndex > 0 else { return }
        undoStack.removeLast()
        currentIndex -= 1
        HapticManager.undo()

        // Rollback session counters
        if var session = currentSession {
            session.totalReviewed -= 1
            session.lastPhotoIndex -= 1

            switch decision {
            case .delete:
                session.totalDeleted -= 1
                session.freedBytes -= photo.fileSize
                // Restore from trash
                try? await trashRepository.restoreFromTrash(id: photo.id)
            case .keep:
                session.totalKept -= 1
            }

            try? await sessionRepository.updateSession(session)
            currentSession = session

            // Update filter index
            await sessionRepository.saveFilterIndex(
                initialOffset + currentIndex,
                forFilter: session.filter
            )
        }

        // Reload thumbnail if evicted by caching window
        if thumbnails[photo.id] == nil {
            let size = AppConstants.Photo.previewSize
            await photoRepository.startCachingThumbnails(for: [photo.id], targetSize: size)
            if let image = await photoRepository.requestPreviewImage(for: photo.id, size: size) {
                thumbnails[photo.id] = image
            }
        }
    }

    // MARK: - Button Actions (for accessibility buttons below card)

    func deleteCurrentPhoto() async {
        await processSwipe(.delete)
    }

    func keepCurrentPhoto() async {
        await processSwipe(.keep)
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

            let pagePhotos = isShuffled ? newPhotos.shuffled() : newPhotos
            photos.append(contentsOf: pagePhotos)
            await loadThumbnails(for: pagePhotos)
        } catch {
            hasMorePhotos = false
        }
    }

    private func loadThumbnails(for newPhotos: [Photo]) async {
        let size = AppConstants.Photo.previewSize
        // Start caching for new photos
        let ids = newPhotos.map(\.id)
        await photoRepository.startCachingThumbnails(for: ids, targetSize: size)

        // Load thumbnails concurrently
        await withTaskGroup(of: (String, UIImage?).self) { group in
            for photo in newPhotos {
                group.addTask { [photoRepository] in
                    let image = await photoRepository.requestPreviewImage(for: photo.id, size: size)
                    return (photo.id, image)
                }
            }
            for await (id, image) in group {
                if let image {
                    thumbnails[id] = image
                }
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

            // Load missing thumbnails concurrently
            let photosToLoad = (aheadStart..<aheadEnd).compactMap { index -> Photo? in
                guard index < photos.count else { return nil }
                let photo = photos[index]
                return thumbnails[photo.id] == nil ? photo : nil
            }
            if !photosToLoad.isEmpty {
                await withTaskGroup(of: (String, UIImage?).self) { group in
                    for photo in photosToLoad {
                        group.addTask { [photoRepository] in
                            let image = await photoRepository.requestPreviewImage(for: photo.id, size: size)
                            return (photo.id, image)
                        }
                    }
                    for await (id, image) in group {
                        if let image {
                            thumbnails[id] = image
                        }
                    }
                }
            }
        }

        // Stop caching behind (keep recent few for undo)
        let behindEnd = max(0, currentIndex - cacheBehindCount)
        if behindEnd > 0 && behindEnd <= photos.count {
            let oldIds = (0..<behindEnd).map { photos[$0].id }
            await photoRepository.stopCachingThumbnails(for: oldIds, targetSize: size)
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
