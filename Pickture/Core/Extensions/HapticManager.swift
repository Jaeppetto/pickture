import UIKit

@MainActor
enum HapticManager {
    static func swipeDelete() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func swipeKeep() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func undo() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func sessionComplete() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func buttonTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
    }
}
