import SwiftUI

struct PhotoPermissionView<Content: View>: View {
    @State var viewModel: PhotoPermissionViewModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            switch viewModel.authorizationStatus {
            case .authorized, .limited:
                content()
            case .notDetermined:
                requestPermissionView
            case .denied, .restricted:
                deniedView
            }
        }
        .animation(.easeInOut(duration: AppConstants.Animation.standardDuration), value: viewModel.authorizationStatus)
    }

    private var requestPermissionView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.primaryGradient)

            VStack(spacing: AppSpacing.xs) {
                Text("사진 접근 권한이 필요합니다")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)

                Text("갤러리를 분석하고 정리하려면\n사진 라이브러리 접근을 허용해주세요")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.md)

            Button {
                Task { await viewModel.requestPermission() }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    if viewModel.isRequesting {
                        ProgressView()
                            .tint(AppColors.primary)
                    }
                    Text("접근 허용하기")
                }
                .glassPrimaryButton()
            }
            .disabled(viewModel.isRequesting)
            .padding(.horizontal, AppSpacing.xl)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var deniedView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: AppSpacing.xs) {
                Text("사진 접근이 거부되었습니다")
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColors.textPrimary)

                Text("설정에서 Pickture의\n사진 접근을 허용해주세요")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.md)

            Button {
                viewModel.openSettings()
            } label: {
                Text("설정으로 이동")
                    .glassPrimaryButton()
            }
            .padding(.horizontal, AppSpacing.xl)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
    }
}
