import SwiftUI

enum AppTypography {
    // MARK: - Headlines

    static let heroTitle = Font.system(size: 34, weight: .black)
    static let pageTitle = Font.system(size: 28, weight: .bold)
    static let sectionTitle = Font.system(size: 22, weight: .bold)
    static let cardTitle = Font.system(size: 17, weight: .semibold)

    // MARK: - Body

    static let body = Font.system(size: 15)
    static let bodyMedium = Font.system(size: 15, weight: .medium)
    static let bodySemibold = Font.system(size: 15, weight: .semibold)

    // MARK: - Small

    static let caption = Font.system(size: 12)
    static let captionMedium = Font.system(size: 12, weight: .medium)
    static let captionSmall = Font.system(size: 11)

    // MARK: - Monospaced

    static let monoLarge = Font.system(size: 34, weight: .bold, design: .monospaced)
    static let monoTitle = Font.system(size: 22, weight: .bold, design: .monospaced)
    static let monoBody = Font.system(size: 15, weight: .semibold, design: .monospaced)
    static let monoCaption = Font.system(size: 12, weight: .medium, design: .monospaced)

    // MARK: - Legacy Aliases

    static let footnote = Font.system(size: 13)
    static let footnoteMedium = Font.system(size: 13, weight: .medium)
    static let title3 = sectionTitle
    static let title2 = pageTitle
    static let title1 = pageTitle
    static let largeTitle = heroTitle
}
