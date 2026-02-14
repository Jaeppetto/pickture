import Foundation

public struct Photo: Sendable, Equatable, Identifiable {
    public let id: String
    public let createdAt: Date
    public let fileSize: Int64
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let type: PhotoType
    public let duration: TimeInterval?
    public let location: Coordinate?
    public let isFavorite: Bool

    public init(
        id: String,
        createdAt: Date,
        fileSize: Int64,
        pixelWidth: Int,
        pixelHeight: Int,
        type: PhotoType,
        duration: TimeInterval? = nil,
        location: Coordinate? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.fileSize = fileSize
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.type = type
        self.duration = duration
        self.location = location
        self.isFavorite = isFavorite
    }
}
