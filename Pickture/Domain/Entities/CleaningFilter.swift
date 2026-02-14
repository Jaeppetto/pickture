import Foundation

public struct CleaningFilter: Sendable, Equatable, Codable {
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

    // MARK: - Custom Codable for ClosedRange<Date>

    private enum CodingKeys: String, CodingKey {
        case photoType, dateRangeLower, dateRangeUpper, minimumFileSize
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photoType = try container.decodeIfPresent(PhotoType.self, forKey: .photoType)
        minimumFileSize = try container.decodeIfPresent(Int64.self, forKey: .minimumFileSize)

        if let lower = try container.decodeIfPresent(Date.self, forKey: .dateRangeLower),
           let upper = try container.decodeIfPresent(Date.self, forKey: .dateRangeUpper) {
            dateRange = lower...upper
        } else {
            dateRange = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(photoType, forKey: .photoType)
        try container.encodeIfPresent(minimumFileSize, forKey: .minimumFileSize)

        if let dateRange {
            try container.encode(dateRange.lowerBound, forKey: .dateRangeLower)
            try container.encode(dateRange.upperBound, forKey: .dateRangeUpper)
        }
    }
}
