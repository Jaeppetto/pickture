import Foundation

public struct StorageInsight: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let category: InsightCategory
    public let suggestedFilter: CleaningFilter?
    public let iconName: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: InsightCategory,
        suggestedFilter: CleaningFilter? = nil,
        iconName: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.suggestedFilter = suggestedFilter
        self.iconName = iconName
    }
}

public enum InsightCategory: String, Sendable, Equatable {
    case screenshots
    case videos
    case largeFiles
    case oldPhotos
    case general
}
