import SwiftUI

struct MainTabView: View {
    let container: AppContainer

    var body: some View {
        TabView(selection: Binding(
            get: { container.navigationCoordinator.selectedTab },
            set: { container.navigationCoordinator.selectedTab = $0 }
        )) {
            HomeScreen(
                viewModel: container.makeHomeViewModel(),
                permissionViewModel: container.photoPermissionViewModel
            )
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            CleanScreen(
                viewModel: container.makeCleanViewModel(),
                permissionViewModel: container.photoPermissionViewModel,
                navigationCoordinator: container.navigationCoordinator,
                deletionQueueViewModelFactory: { [container] in
                    container.makeDeletionQueueViewModel()
                },
                photoRepository: container.photoRepository
            )
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
