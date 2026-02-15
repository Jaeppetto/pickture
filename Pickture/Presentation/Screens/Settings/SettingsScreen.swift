import SwiftUI

struct SettingsScreen: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("테마") {
                    Picker("화면 모드", selection: Binding(
                        get: { viewModel.preferences.themeMode },
                        set: { newValue in
                            Task { await viewModel.updateThemeMode(newValue) }
                        }
                    )) {
                        Text("시스템").tag(ThemeMode.system)
                        Text("라이트").tag(ThemeMode.light)
                        Text("다크").tag(ThemeMode.dark)
                    }
                    .tint(AppColors.chrome)
                }

                Section("정리") {
                    Toggle("햅틱 피드백", isOn: Binding(
                        get: { viewModel.preferences.hapticEnabled },
                        set: { newValue in
                            Task { await viewModel.updateHapticEnabled(newValue) }
                        }
                    ))
                    .tint(AppColors.chrome)
                }

                Section("앱 정보") {
                    HStack {
                        Label("버전", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadPreferences()
        }
    }
}
