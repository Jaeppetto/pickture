import SwiftUI

struct CleanScreen: View {
    @State var viewModel: CleanViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.primaryGradient)

                VStack(spacing: AppSpacing.xs) {
                    Text("사진 정리")
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("스와이프로 빠르게 정리하세요")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Button {
                    Task {
                        await viewModel.startNewSession()
                    }
                } label: {
                    Text("정리 시작")
                        .font(AppTypography.bodySemibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
                }
                .padding(.horizontal, AppSpacing.xxl)

                Spacer()
            }
            .background(AppColors.background)
            .navigationTitle("정리")
        }
        .task {
            await viewModel.checkForActiveSession()
        }
    }
}
