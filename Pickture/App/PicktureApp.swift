import SwiftUI

@main
struct PicktureApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}

private struct RootView: View {
    let container: AppContainer
    @State private var showSplash = true
    @State private var showLanguageToast = false
    @State private var toastMessage = ""
    @State private var toastWorkItem: DispatchWorkItem?

    var body: some View {
        ZStack {
            MainTabView(container: container)
                .preferredColorScheme(container.theme.colorScheme)
                .environment(\.locale, resolvedLocale)
                .task {
                    await container.settingsViewModel.loadPreferences()
                }
                .onChange(of: container.settingsViewModel.preferences.locale) { _, newLocale in
                    toastWorkItem?.cancel()
                    toastMessage = languageChangeMessage(for: newLocale)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showLanguageToast = true
                    }
                    let workItem = DispatchWorkItem {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showLanguageToast = false
                        }
                    }
                    toastWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
                }
                .overlay(alignment: .top) {
                    if showLanguageToast {
                        Text(toastMessage)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.regularMaterial, in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.top, 60)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }

            if showSplash {
                SplashScreenView()
                    .transition(.opacity.animation(.easeOut(duration: 0.4)))
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }

    private func languageChangeMessage(for locale: String) -> String {
        switch locale {
        case "system": "System language applied"
        case "ko": "언어가 한국어로 변경되었습니다"
        case "en": "Language changed to English"
        case "ja": "言語が日本語に変更されました"
        case "zh-Hans": "语言已更改为中文"
        default: "Language changed"
        }
    }

    private var resolvedLocale: Locale {
        let selectedLocale = container.settingsViewModel.preferences.locale
        guard selectedLocale != "system" else { return .autoupdatingCurrent }
        return Locale(identifier: selectedLocale)
    }
}
