import SwiftUI

enum AppTypography {
    // MARK: - Size Scale

    static let size12: CGFloat = 12
    static let size14: CGFloat = 14
    static let size16: CGFloat = 16
    static let size20: CGFloat = 20
    static let size24: CGFloat = 24
    static let size32: CGFloat = 32
    static let size40: CGFloat = 40

    // MARK: - Text Styles

    static let caption = Font.system(size: size12, weight: .regular)
    static let captionMedium = Font.system(size: size12, weight: .medium)
    static let footnote = Font.system(size: size14, weight: .regular)
    static let footnoteMedium = Font.system(size: size14, weight: .medium)
    static let body = Font.system(size: size16, weight: .regular)
    static let bodyMedium = Font.system(size: size16, weight: .medium)
    static let bodySemibold = Font.system(size: size16, weight: .semibold)
    static let title3 = Font.system(size: size20, weight: .semibold)
    static let title2 = Font.system(size: size24, weight: .bold)
    static let title1 = Font.system(size: size32, weight: .bold)
    static let largeTitle = Font.system(size: size40, weight: .bold)

    // MARK: - Monospaced (for numbers/stats)

    static let monoCaption = Font.system(size: size12, weight: .medium, design: .monospaced)
    static let monoBody = Font.system(size: size16, weight: .semibold, design: .monospaced)
    static let monoTitle = Font.system(size: size24, weight: .bold, design: .monospaced)
    static let monoLarge = Font.system(size: size40, weight: .bold, design: .monospaced)
}
