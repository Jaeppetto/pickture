import Foundation

public enum PhotoType: String, Sendable, Equatable, CaseIterable, Codable {
    case image
    case video
    case screenshot
    case gif
    case livePhoto
}
