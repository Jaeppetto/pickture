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
                permissionViewModel: container.photoPermissionViewModel,
                settingsViewModel: container.settingsViewModel,
                deletionQueueViewModelFactory: { [container] in
                    container.makeDeletionQueueViewModel()
                }
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
        }
        .tint(AppColors.ink)
        .toolbarBackground(AppColors.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

enum AppTab: Hashable {
    case home
    case clean
}
