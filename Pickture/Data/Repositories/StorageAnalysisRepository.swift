import Foundation

final class StorageAnalysisRepository: StorageAnalysisRepositoryProtocol, @unchecked Sendable {
    private let photoDataSource: PhotoLibraryDataSource

    init(photoDataSource: PhotoLibraryDataSource) {
        self.photoDataSource = photoDataSource
    }

    func analyzeStorage() async throws -> StorageInfo {
        let deviceInfo = try await getDeviceStorageInfo()
        let mediaStats = await photoDataSource.calculateStorageByType()

        return StorageInfo(
            totalDeviceStorage: deviceInfo.total,
            usedDeviceStorage: deviceInfo.used,
            totalPhotoCount: mediaStats.photoCount,
            totalVideoCount: mediaStats.videoCount,
            totalScreenshotCount: mediaStats.screenshotCount,
            photoStorageBytes: mediaStats.photoBytes,
            videoStorageBytes: mediaStats.videoBytes,
            screenshotStorageBytes: mediaStats.screenshotBytes,
            otherMediaBytes: mediaStats.otherBytes
        )
    }

    func getDeviceStorageInfo() async throws -> (total: Int64, used: Int64) {
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let values = try homeURL.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
        ])

        let total = Int64(values.volumeTotalCapacity ?? 0)
        let available = values.volumeAvailableCapacityForImportantUsage ?? 0

        return (total: total, used: total - available)
    }
}
