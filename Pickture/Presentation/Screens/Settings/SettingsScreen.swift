import SwiftUI

struct SettingsScreen: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    settingsSection(title: "정리") {
                        settingsRow {
                            Toggle("햅틱 피드백", isOn: Binding(
                                get: { viewModel.preferences.hapticEnabled },
                                set: { newValue in
                                    Task { await viewModel.updateHapticEnabled(newValue) }
                                }
                            ))
                            .tint(AppColors.accentYellow)
                        }
                    }

                    settingsSection(title: "언어") {
                        settingsRow {
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
                            .tint(AppColors.ink)
                        }
                    }

                    settingsSection(title: "앱 정보") {
                        settingsRow {
                            HStack {
                                Label("버전", systemImage: "info.circle")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundStyle(AppColors.inkMuted)
                            }
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadPreferences()
        }
    }

    // MARK: - Brutalist Settings Components

    private func settingsSection<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .textCase(.uppercase)
                .font(AppTypography.captionMedium)
                .foregroundStyle(AppColors.ink)
                .padding(.bottom, AppSpacing.xxs)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(AppColors.accentYellow)
                        .frame(height: 3)
                        .offset(y: 2)
                }

            content()
        }
    }

    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(AppSpacing.sm)
            .background(AppColors.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall, style: .continuous)
                    .strokeBorder(AppColors.border, lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall, style: .continuous))
    }
}
