import Foundation

public struct StorageInfo: Sendable, Equatable {
    public let totalDeviceStorage: Int64
    public let usedDeviceStorage: Int64
    public let totalPhotoCount: Int
    public let totalVideoCount: Int
    public let totalScreenshotCount: Int
    public let photoStorageBytes: Int64
    public let videoStorageBytes: Int64
    public let screenshotStorageBytes: Int64
    public let otherMediaBytes: Int64

    public init(
        totalDeviceStorage: Int64 = 0,
        usedDeviceStorage: Int64 = 0,
        totalPhotoCount: Int = 0,
        totalVideoCount: Int = 0,
        totalScreenshotCount: Int = 0,
        photoStorageBytes: Int64 = 0,
        videoStorageBytes: Int64 = 0,
        screenshotStorageBytes: Int64 = 0,
        otherMediaBytes: Int64 = 0
    ) {
        self.totalDeviceStorage = totalDeviceStorage
        self.usedDeviceStorage = usedDeviceStorage
        self.totalPhotoCount = totalPhotoCount
        self.totalVideoCount = totalVideoCount
        self.totalScreenshotCount = totalScreenshotCount
        self.photoStorageBytes = photoStorageBytes
        self.videoStorageBytes = videoStorageBytes
        self.screenshotStorageBytes = screenshotStorageBytes
        self.otherMediaBytes = otherMediaBytes
    }

    public var totalMediaCount: Int {
        totalPhotoCount + totalVideoCount + totalScreenshotCount
    }

    public var totalMediaBytes: Int64 {
        photoStorageBytes + videoStorageBytes + screenshotStorageBytes + otherMediaBytes
    }

    public var availableDeviceStorage: Int64 {
        totalDeviceStorage - usedDeviceStorage
    }
}
