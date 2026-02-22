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
    private var shuffledIndices: [Int] = []
    private var shuffledPageOffset: Int = 0

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
    private let analyticsService: any AnalyticsServiceProtocol

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
        trashRepository: any TrashRepositoryProtocol,
        analyticsService: any AnalyticsServiceProtocol
    ) {
        self.photoRepository = photoRepository
        self.startSessionUseCase = startSessionUseCase
        self.processDecisionUseCase = processDecisionUseCase
        self.completeSessionUseCase = completeSessionUseCase
        self.sessionRepository = sessionRepository
        self.trashRepository = trashRepository
        self.analyticsService = analyticsService
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
        // Check for saved index — skip when user explicitly chose a start offset or shuffle
        if !shuffled, startOffset == 0,
           let savedIndex = await sessionRepository.loadFilterIndex(forFilter: filter), savedIndex > 0 {
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
        // Check for saved index like startNewSession
        if let savedIndex = await sessionRepository.loadFilterIndex(forFilter: filter), savedIndex > 0 {
            pendingResumeFilter = filter
            pendingResumeIndex = savedIndex
            showResumeAlert = true
            return
        }
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

            // Phase 1: metadata only (fast) — UI appears immediately
            let fullCount = try await photoRepository.fetchPhotoCount(filter: filter)
            totalPhotoCount = max(0, fullCount - initialOffset)

            if isShuffled {
                shuffledIndices = Array(0..<fullCount).shuffled()
                shuffledPageOffset = 0
            }

            await loadNextPageMetadata(filter: filter)
            screenState = .cleaning

            let event = AnalyticsEvent.sessionStarted(
                filter: filter?.photoType?.rawValue ?? "all",
                photoCount: totalPhotoCount
            )
            analyticsService.logEvent(event.name, parameters: event.parameters)

            // Phase 2: priority thumbnails (current + next few — immediate)
            await loadPriorityThumbnails()

            // Phase 3: remaining thumbnails (non-blocking background)
            Task { @MainActor [weak self] in
                await self?.loadThumbnailsForCurrentPage()
            }
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

            let duration = completed.endedAt?.timeIntervalSince(completed.startedAt) ?? 0
            let event = AnalyticsEvent.sessionCompleted(
                kept: completed.totalKept,
                deleted: completed.totalDeleted,
                duration: duration
            )
            analyticsService.logEvent(event.name, parameters: event.parameters)
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
        shuffledIndices = []
        shuffledPageOffset = 0
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

            let swipeEvent = AnalyticsEvent.swipeDecision(
                decision: decision == .delete ? "delete" : "keep",
                photoIndex: currentIndex
            )
            analyticsService.logEvent(swipeEvent.name, parameters: swipeEvent.parameters)

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

        let event = AnalyticsEvent.undoDecision
        analyticsService.logEvent(event.name, parameters: event.parameters)

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
        await loadNextPageMetadata(filter: filter)

        // Load priority thumbnails immediately, rest in background
        await loadPriorityThumbnails()
        Task { @MainActor [weak self] in
            await self?.loadThumbnailsForCurrentPage()
        }
    }

    private func loadNextPageMetadata(filter: CleaningFilter?) async {
        guard !isLoadingPhotos, hasMorePhotos else { return }
        isLoadingPhotos = true
        defer { isLoadingPhotos = false }

        do {
            if isShuffled {
                let endIndex = min(shuffledPageOffset + pageSize, shuffledIndices.count)
                guard shuffledPageOffset < endIndex else {
                    hasMorePhotos = false
                    return
                }

                let pageIndices = Array(shuffledIndices[shuffledPageOffset..<endIndex])
                let newPhotos = try await photoRepository.fetchPhotosByIndices(
                    pageIndices,
                    filter: filter
                )
                shuffledPageOffset = endIndex

                if endIndex >= shuffledIndices.count {
                    hasMorePhotos = false
                }

                photos.append(contentsOf: newPhotos)
            } else {
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
            }
        } catch {
            hasMorePhotos = false
        }
    }

    private func loadPriorityThumbnails() async {
        let start = currentIndex
        let end = min(start + cacheAheadCount + 1, photos.count)
        guard start < end else { return }

        let priorityPhotos = (start..<end).compactMap { index -> Photo? in
            let photo = photos[index]
            return thumbnails[photo.id] == nil ? photo : nil
        }
        guard !priorityPhotos.isEmpty else { return }

        let size = AppConstants.Photo.previewSize
        await photoRepository.startCachingThumbnails(for: priorityPhotos.map(\.id), targetSize: size)

        await withTaskGroup(of: (String, UIImage?).self) { group in
            for photo in priorityPhotos {
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

    private func loadThumbnailsForCurrentPage() async {
        let photosNeedingThumbnails = photos.filter { thumbnails[$0.id] == nil }
        guard !photosNeedingThumbnails.isEmpty else { return }

        let size = AppConstants.Photo.previewSize
        let ids = photosNeedingThumbnails.map(\.id)
        await photoRepository.startCachingThumbnails(for: ids, targetSize: size)

        await withTaskGroup(of: (String, UIImage?).self) { group in
            for photo in photosNeedingThumbnails {
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
