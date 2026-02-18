import SwiftUI

struct SessionSummaryView: View {
    let session: CleaningSession
    let onReviewDeletionQueue: () -> Void
    let onDone: () -> Void

    @Environment(\.locale) private var locale
    @State private var showStats = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if showStats {
                ConfettiView()
                    .ignoresSafeArea()
            }

            VStack(spacing: AppSpacing.xxl) {
                Spacer()

                // Celebration icon
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(AppColors.primaryGradient)
                    .scaleEffect(showStats ? 1 : 0.5)
                    .opacity(showStats ? 1 : 0)

                // Title
                VStack(spacing: AppSpacing.xs) {
                    Text("정리 완료!")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.textPrimary)

                    if session.freedBytes > 0 {
                        Text("\(session.freedBytes.formattedBytes) 확보")
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primary)
                    }
                }

                // Stats cards
                statsGrid
                    .opacity(showStats ? 1 : 0)
                    .offset(y: showStats ? 0 : 20)

                // Duration
                if let duration = sessionDuration {
                    Text("소요 시간: \(duration)")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Actions
                VStack(spacing: AppSpacing.sm) {
                    if session.totalDeleted > 0 {
                        Button(action: onReviewDeletionQueue) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "trash")
                                Text("삭제 대기열 확인 (\(session.totalDeleted))")
                            }
                            .subtleButton(tint: AppColors.delete)
                        }
                    }

                    Button(action: onDone) {
                        Text("완료")
                            .glassPrimaryButton()
                    }
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showStats = true
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: AppSpacing.sm) {
            statCard(
                value: session.totalReviewed,
                label: "검토",
                icon: "eye.fill",
                color: AppColors.primary
            )
            statCard(
                value: session.totalDeleted,
                label: "삭제",
                icon: "trash.fill",
                color: AppColors.delete
            )
            statCard(
                value: session.totalKept,
                label: "보관",
                icon: "checkmark",
                color: AppColors.keep
            )
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func statCard(value: Int, label: LocalizedStringKey, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: Circle())

            AnimatedCounterView(
                targetValue: value,
                font: AppTypography.monoTitle,
                color: AppColors.textPrimary
            )

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .surfaceStyle()
    }

    // MARK: - Helpers

    private var sessionDuration: String? {
        guard let endedAt = session.endedAt else { return nil }
        let interval = endedAt.timeIntervalSince(session.startedAt)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60

        if minutes > 0 {
            let format = String(localized: "%@분 %@초", locale: locale)
            return String(format: format, locale: locale, String(minutes), String(seconds))
        }
        let format = String(localized: "%@초", locale: locale)
        return String(format: format, locale: locale, String(seconds))
    }
}
