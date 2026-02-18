import SwiftUI

struct SettingsScreen: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("정리") {
                    Toggle("햅틱 피드백", isOn: Binding(
                        get: { viewModel.preferences.hapticEnabled },
                        set: { newValue in
                            Task { await viewModel.updateHapticEnabled(newValue) }
                        }
                    ))
                    .tint(AppColors.chrome)
                }

                Section("언어") {
                    Picker("앱 언어", selection: Binding(
                        get: { viewModel.preferences.locale },
                        set: { newValue in
                            Task { await viewModel.updateLocale(newValue) }
                        }
                    )) {
                        Text("시스템 언어").tag("system")
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                        Text("日本語").tag("ja")
                        Text("中文").tag("zh-Hans")
                    }
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
