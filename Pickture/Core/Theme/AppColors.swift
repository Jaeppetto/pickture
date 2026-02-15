import SwiftUI

enum AppColors {
    // MARK: - Semantic Colors

    static let background = Color(uiColor: .systemGray6)
    static let surface = Color(uiColor: .systemBackground)
    static let primary = Color.black
    static let secondary = Color(uiColor: .secondaryLabel)
    static let delete = Color.red
    static let keep = Color.green
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let cardBorder = Color.primary.opacity(0.12)
    static let overlayScrim = Color.black.opacity(0.4)
    static let video = Color(uiColor: .tertiaryLabel)
    static let screenshot = Color(uiColor: .tertiaryLabel)
    static let chrome = Color.black
    static let chartPhoto = Color(uiColor: .label)
    static let chartVideo = Color(uiColor: .systemGray2)
    static let chartScreenshot = Color(uiColor: .systemGray3)
    static let chartOther = Color(uiColor: .systemGray4)

    // MARK: - Gradients

    static let primaryGradient = LinearGradient(
        colors: [chrome, chrome.opacity(0.78)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let deleteGradient = LinearGradient(
        colors: [Color.red, Color.red.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let keepGradient = LinearGradient(
        colors: [Color.green, Color.green.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
