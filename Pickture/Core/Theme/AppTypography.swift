import SwiftUI

enum AppTypography {
    // MARK: - Text Styles

    static let caption = Font.caption2
    static let captionMedium = Font.caption2.weight(.medium)
    static let footnote = Font.footnote
    static let footnoteMedium = Font.footnote.weight(.medium)
    static let body = Font.body
    static let bodyMedium = Font.body.weight(.medium)
    static let bodySemibold = Font.body.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    static let title2 = Font.title2.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let largeTitle = Font.largeTitle.weight(.bold)

    // MARK: - Monospaced (for numbers/stats)

    static let monoCaption = Font.system(.caption2, design: .monospaced).weight(.medium)
    static let monoBody = Font.system(.body, design: .monospaced).weight(.semibold)
    static let monoTitle = Font.system(.title3, design: .monospaced).weight(.bold)
    static let monoLarge = Font.system(.largeTitle, design: .monospaced).weight(.bold)
}
