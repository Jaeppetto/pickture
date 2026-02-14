import SwiftUI

enum AppColors {
    // MARK: - Semantic Colors (from Asset Catalog)

    static let background = Color("Background")
    static let surface = Color("Surface")
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let delete = Color("Delete")
    static let keep = Color("Keep")
    static let favorite = Color("Favorite")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    // MARK: - Gradients

    static let primaryGradient = LinearGradient(
        colors: [Color(hex: 0x2D5BFF), Color(hex: 0x7C3AED)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let deleteGradient = LinearGradient(
        colors: [Color(hex: 0xFF3B30), Color(hex: 0xFF6B6B)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let keepGradient = LinearGradient(
        colors: [Color(hex: 0x34C759), Color(hex: 0x7AE5A0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let favoriteGradient = LinearGradient(
        colors: [Color(hex: 0xFF9500), Color(hex: 0xFFD60A)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
