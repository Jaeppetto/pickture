import SwiftUI

enum AppColors {
    // MARK: - Base Colors

    static let background = Color(red: 0xF5 / 255, green: 0xF0 / 255, blue: 0xEB / 255)
    static let surface = Color.white
    static let ink = Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255)
    static let inkMuted = Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255).opacity(0.55)
    static let inkFaint = Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255).opacity(0.2)

    // MARK: - Accent "Brutalist 5"

    static let accentYellow = Color(red: 0xFF / 255, green: 0xD4 / 255, blue: 0x3B / 255)
    static let accentRed = Color(red: 0xFF / 255, green: 0x45 / 255, blue: 0x45 / 255)
    static let accentGreen = Color(red: 0x51 / 255, green: 0xCF / 255, blue: 0x66 / 255)
    static let accentBlue = Color(red: 0x4D / 255, green: 0xAB / 255, blue: 0xF7 / 255)
    static let accentPurple = Color(red: 0xB1 / 255, green: 0x97 / 255, blue: 0xFC / 255)

    // MARK: - Semantic Mappings

    static let primary = accentYellow
    static let delete = accentRed
    static let keep = accentGreen

    // MARK: - Border & Shadow

    static let border = ink
    static let shadowColor = ink

    // MARK: - Chart Colors

    static let chartPhoto = accentYellow
    static let chartVideo = accentBlue
    static let chartScreenshot = accentPurple
    static let chartOther = ink

    // MARK: - Overlay

    static let overlayScrim = Color.black.opacity(0.4)

    // MARK: - Legacy Aliases (Migration Compatibility)

    static let textPrimary = ink
    static let textSecondary = inkMuted
    static let chrome = ink
    static let secondary = inkMuted
    static let video = accentBlue
    static let screenshot = accentPurple
    static let cardBorder = border
}
