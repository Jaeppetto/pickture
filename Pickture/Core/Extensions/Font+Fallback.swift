import SwiftUI

extension Font {
    static func pretendard(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String = switch weight {
        case .bold:
            "Pretendard-Bold"
        case .semibold:
            "Pretendard-SemiBold"
        case .medium:
            "Pretendard-Medium"
        case .light:
            "Pretendard-Light"
        default:
            "Pretendard-Regular"
        }

        if UIFont(name: fontName, size: size) != nil {
            return .custom(fontName, size: size)
        }
        return .system(size: size, weight: weight)
    }
}
