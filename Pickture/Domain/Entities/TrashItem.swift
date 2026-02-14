import Foundation

public struct TrashItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let photoId: String
    public let deletedAt: Date
    public let expiresAt: Date
    public let fileSize: Int64

    public init(
        id: String = UUID().uuidString,
        photoId: String,
        deletedAt: Date = .now,
        expiresAt: Date? = nil,
        fileSize: Int64
    ) {
        self.id = id
        self.photoId = photoId
        self.deletedAt = deletedAt
        if let expiresAt {
            self.expiresAt = expiresAt
        } else {
            self.expiresAt = Calendar.current.date(byAdding: .day, value: 30, to: deletedAt)
                ?? deletedAt.addingTimeInterval(30 * 24 * 60 * 60)
        }
        self.fileSize = fileSize
    }

    public var isExpired: Bool {
        Date.now >= expiresAt
    }
}
