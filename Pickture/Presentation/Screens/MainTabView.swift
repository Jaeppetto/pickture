import SwiftUI

struct MainTabView: View {
    let container: AppContainer

    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(viewModel: container.makeHomeViewModel())
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            CleanScreen(viewModel: container.makeCleanViewModel())
                .tabItem {
                    Label("정리", systemImage: "sparkles")
                }
                .tag(AppTab.clean)

            SettingsScreen(viewModel: container.makeSettingsViewModel())
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(AppColors.primary)
    }
}

enum AppTab: Hashable {
    case home
    case clean
    case settings
}
