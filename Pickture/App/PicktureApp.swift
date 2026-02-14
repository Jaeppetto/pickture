import SwiftUI

@main
struct PicktureApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
                .preferredColorScheme(container.theme.colorScheme)
        }
    }
}
