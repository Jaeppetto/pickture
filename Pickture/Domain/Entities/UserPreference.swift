import Foundation

public struct UserPreference: Sendable, Equatable, Codable {
    public var dailyGoal: Int
    public var themeMode: ThemeMode
    public var locale: String
    public var hapticEnabled: Bool

    public init(
        dailyGoal: Int = 30,
        themeMode: ThemeMode = .system,
        locale: String = "ko",
        hapticEnabled: Bool = true
    ) {
        self.dailyGoal = dailyGoal
        self.themeMode = themeMode
        self.locale = locale
        self.hapticEnabled = hapticEnabled
    }

    public static let `default` = Self()
}
