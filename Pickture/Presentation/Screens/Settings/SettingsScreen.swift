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
                }

                Section("정리") {
                    HStack {
                        Text("일일 목표")
                        Spacer()
                        Text("\(viewModel.preferences.dailyGoal)장")
                            .font(AppTypography.monoBody)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Toggle("햅틱 피드백", isOn: Binding(
                        get: { viewModel.preferences.hapticEnabled },
                        set: { newValue in
                            Task { await viewModel.updateHapticEnabled(newValue) }
                        }
                    ))
                }

                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("설정")
        }
        .task {
            await viewModel.loadPreferences()
        }
    }
}
