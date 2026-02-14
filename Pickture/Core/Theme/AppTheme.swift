import SwiftUI

@MainActor @Observable
final class AppTheme {
    private(set) var mode: ThemeMode

    init(mode: ThemeMode = .system) {
        self.mode = mode
    }

    var colorScheme: ColorScheme? {
        switch mode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func setMode(_ newMode: ThemeMode) {
        mode = newMode
    }
}
