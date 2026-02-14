import Foundation

public enum PhotoType: String, Sendable, Equatable, CaseIterable {
    case image
    case video
    case screenshot
    case gif
    case livePhoto
}
