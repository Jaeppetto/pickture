import Foundation

public struct UserPreference: Sendable, Equatable, Codable {
    public var themeMode: ThemeMode
    public var locale: String
    public var hapticEnabled: Bool

    public init(
        themeMode: ThemeMode = .system,
        locale: String = "ko",
        hapticEnabled: Bool = true
    ) {
        self.themeMode = themeMode
        self.locale = locale
        self.hapticEnabled = hapticEnabled
    }

    public static let `default` = Self()
}
