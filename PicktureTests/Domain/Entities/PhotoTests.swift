import Foundation
import Testing

@testable import Pickture

@Suite("Photo Entity Tests")
struct PhotoTests {
    @Test("Photo initializes with correct default values")
    func initializesWithDefaults() {
        let photo = Photo(
            id: "test-id",
            createdAt: Date(timeIntervalSince1970: 1_000_000),
            fileSize: 1024,
            pixelWidth: 1920,
            pixelHeight: 1080,
            type: .image
        )

        #expect(photo.id == "test-id")
        #expect(photo.fileSize == 1024)
        #expect(photo.pixelWidth == 1920)
        #expect(photo.pixelHeight == 1080)
        #expect(photo.type == .image)
        #expect(photo.duration == nil)
        #expect(photo.location == nil)
        #expect(photo.isFavorite == false)
    }

    @Test("Photo supports video with duration")
    func videoWithDuration() {
        let photo = Photo(
            id: "video-id",
            createdAt: .now,
            fileSize: 50_000_000,
            pixelWidth: 3840,
            pixelHeight: 2160,
            type: .video,
            duration: 120.5
        )

        #expect(photo.type == .video)
        #expect(photo.duration == 120.5)
    }

    @Test("Photo with location has coordinate")
    func photoWithLocation() {
        let coordinate = Coordinate(latitude: 37.5665, longitude: 126.9780)
        let photo = Photo(
            id: "loc-id",
            createdAt: .now,
            fileSize: 2048,
            pixelWidth: 4032,
            pixelHeight: 3024,
            type: .image,
            location: coordinate
        )

        #expect(photo.location?.latitude == 37.5665)
        #expect(photo.location?.longitude == 126.9780)
    }

    @Test("Photo equality compares all properties")
    func equality() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let photo1 = Photo(id: "id", createdAt: date, fileSize: 100, pixelWidth: 100, pixelHeight: 100, type: .image)
        let photo2 = Photo(id: "id", createdAt: date, fileSize: 100, pixelWidth: 100, pixelHeight: 100, type: .image)

        #expect(photo1 == photo2)
    }
}

@Suite("CleaningSession Tests")
struct CleaningSessionTests {
    @Test("Session initializes with active status")
    func initializesAsActive() {
        let session = CleaningSession()

        #expect(session.status == .active)
        #expect(session.totalReviewed == 0)
        #expect(session.totalDeleted == 0)
        #expect(session.totalKept == 0)
        #expect(session.totalFavorited == 0)
        #expect(session.freedBytes == 0)
        #expect(session.endedAt == nil)
    }

    @Test("Session with filter preserves filter")
    func sessionWithFilter() {
        let filter = CleaningFilter(photoType: .screenshot)
        let session = CleaningSession(filter: filter)

        #expect(session.filter?.photoType == .screenshot)
    }
}

@Suite("TrashItem Tests")
struct TrashItemTests {
    @Test("TrashItem expires after 30 days")
    func expiresAfter30Days() {
        let deletedAt = Date(timeIntervalSince1970: 0)
        let item = TrashItem(photoId: "photo-1", deletedAt: deletedAt, fileSize: 1024)

        let expectedExpiry = Calendar.current.date(byAdding: .day, value: 30, to: deletedAt)
        #expect(item.expiresAt == expectedExpiry)
    }
}

@Suite("StorageInfo Tests")
struct StorageInfoTests {
    @Test("StorageInfo computes totals correctly")
    func computesTotals() {
        let info = StorageInfo(
            totalDeviceStorage: 256_000_000_000,
            usedDeviceStorage: 200_000_000_000,
            totalPhotoCount: 1000,
            totalVideoCount: 50,
            totalScreenshotCount: 200,
            photoStorageBytes: 5_000_000_000,
            videoStorageBytes: 10_000_000_000,
            screenshotStorageBytes: 500_000_000,
            otherMediaBytes: 100_000_000
        )

        #expect(info.totalMediaCount == 1250)
        #expect(info.totalMediaBytes == 15_600_000_000)
        #expect(info.availableDeviceStorage == 56_000_000_000)
    }
}
