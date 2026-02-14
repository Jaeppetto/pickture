import Foundation

public struct CleaningFilter: Sendable, Equatable {
    public let photoType: PhotoType?
    public let dateRange: ClosedRange<Date>?
    public let minimumFileSize: Int64?

    public init(
        photoType: PhotoType? = nil,
        dateRange: ClosedRange<Date>? = nil,
        minimumFileSize: Int64? = nil
    ) {
        self.photoType = photoType
        self.dateRange = dateRange
        self.minimumFileSize = minimumFileSize
    }

    public static let all = Self()

    public static func screenshotsOnly() -> Self {
        Self(photoType: .screenshot)
    }

    public static func videosOnly() -> Self {
        Self(photoType: .video)
    }

    public static func largeFiles(minimumBytes: Int64 = 10_485_760) -> Self {
        Self(minimumFileSize: minimumBytes)
    }
}
