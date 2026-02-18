import SwiftUI

enum AppSpacing {
    // MARK: - Spacing Scale

    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48

    // MARK: - Corner Radius Scale

    enum CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 10
        static let extraLarge: CGFloat = 14
        static let full: CGFloat = 9999
    }

    // MARK: - Brutalist Tokens

    enum BrutalistTokens {
        static let borderWidth: CGFloat = 2.5
        static let borderWidthThick: CGFloat = 3.5
        static let shadowOffset: CGFloat = 4
        static let shadowOffsetLarge: CGFloat = 6
        static let cornerRadius: CGFloat = 10
        static let cornerRadiusSmall: CGFloat = 6
        static let cornerRadiusLarge: CGFloat = 14
    }
}
