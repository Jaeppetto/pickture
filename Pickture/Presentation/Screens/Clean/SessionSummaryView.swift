import SwiftUI

struct SessionSummaryView: View {
    let session: CleaningSession
    let onReviewDeletionQueue: () -> Void
    let onDone: () -> Void

    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visiblePhases: Set<SessionSummaryRevealPhase> = []

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.xxl) {
                Spacer()

                PicktureCelebrationIcon(isPresented: isVisible(.icon))

                VStack(spacing: AppSpacing.xs) {
                    Text("정리 완료!")
                        .font(AppTypography.heroTitle)
                        .foregroundStyle(AppColors.ink)

                    if session.freedBytes > 0 {
                        Text("\(session.freedBytes.formattedBytes) 확보")
                            .font(AppTypography.sectionTitle)
                            .foregroundStyle(AppColors.ink)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xxs)
                            .background(AppColors.accentYellow)
                    }
                }
                .opacity(isVisible(.title) ? 1 : 0)
                .offset(y: revealOffset(for: .title))

                statsGrid
                    .opacity(isVisible(.stats) ? 1 : 0)
                    .offset(y: revealOffset(for: .stats))

                if let duration = sessionDurationComponents {
                    Text("소요 시간: \(duration)")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.inkMuted)
                        .opacity(isVisible(.actions) ? 1 : 0)
                        .offset(y: revealOffset(for: .actions, distance: 10))
                }

                Spacer()

                VStack(spacing: AppSpacing.sm) {
                    if session.totalDeleted > 0 {
                        Button(action: onReviewDeletionQueue) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "trash")
                                Text("삭제 대기열 확인 (\(String(session.totalDeleted)))")
                            }
                        }
                        .buttonStyle(.brutalistSecondary)
                    }

                    Button(action: onDone) {
                        Text("완료")
                    }
                    .buttonStyle(.brutalistPrimary)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
                .opacity(isVisible(.actions) ? 1 : 0)
                .offset(y: revealOffset(for: .actions))
            }

            if isVisible(.icon) {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .onAppear {
            revealContent()
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: AppSpacing.sm) {
            statCard(
                value: session.totalReviewed,
                label: "검토",
                icon: "eye.fill",
                color: AppColors.accentBlue
            )
            statCard(
                value: session.totalDeleted,
                label: "삭제",
                icon: "trash.fill",
                color: AppColors.accentRed
            )
            statCard(
                value: session.totalKept,
                label: "보관",
                icon: "checkmark",
                color: AppColors.accentGreen
            )
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func statCard(value: Int, label: LocalizedStringKey, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppColors.ink)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.2), in: Circle())
                .overlay {
                    Circle().strokeBorder(AppColors.border, lineWidth: 1.5)
                }

            AnimatedCounterView(
                targetValue: value,
                font: AppTypography.monoTitle,
                color: AppColors.ink
            )

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .brutalistCard(accent: color)
    }

    // MARK: - Helpers

    private var sessionDurationComponents: String? {
        guard let endedAt = session.endedAt else { return nil }
        let interval = endedAt.timeIntervalSince(session.startedAt)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = interval >= 60 ? [.minute, .second] : [.second]
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = locale
        return formatter.string(from: interval)
    }

    private func revealContent() {
        guard visiblePhases.isEmpty else { return }

        let timeline = SessionSummaryRevealTimeline(reduceMotion: reduceMotion)
        for phase in SessionSummaryRevealPhase.allCases {
            Task { @MainActor in
                let delay = timeline.delay(for: phase)
                if delay > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }

                withAnimation(timeline.animation) {
                    visiblePhases.insert(phase)
                }
            }
        }
    }

    private func isVisible(_ phase: SessionSummaryRevealPhase) -> Bool {
        visiblePhases.contains(phase)
    }

    private func revealOffset(for phase: SessionSummaryRevealPhase, distance: CGFloat = 18) -> CGFloat {
        guard !reduceMotion else { return isVisible(phase) ? 0 : distance / 2 }
        return isVisible(phase) ? 0 : distance
    }
}

enum SessionSummaryRevealPhase: CaseIterable {
    case icon
    case title
    case stats
    case actions
}

struct SessionSummaryRevealTimeline {
    let reduceMotion: Bool

    func delay(for phase: SessionSummaryRevealPhase) -> TimeInterval {
        switch (reduceMotion, phase) {
        case (true, .icon): 0
        case (true, .title): 0.08
        case (true, .stats): 0.16
        case (true, .actions): 0.24
        case (false, .icon): 0.1
        case (false, .title): 0.24
        case (false, .stats): 0.38
        case (false, .actions): 0.52
        }
    }

    var animation: Animation {
        if reduceMotion {
            .easeOut(duration: 0.18)
        } else {
            .spring(response: 0.52, dampingFraction: 0.72)
        }
    }
}

private struct PicktureCelebrationIcon: View {
    let isPresented: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            burstPiece(
                color: AppColors.accentRed,
                size: CGSize(width: 16, height: 16),
                rotation: -12,
                offset: CGSize(width: -48, height: -38)
            )

            burstPiece(
                color: AppColors.accentPurple,
                size: CGSize(width: 14, height: 14),
                rotation: 0,
                offset: CGSize(width: 47, height: -24),
                isCircle: true
            )

            burstPiece(
                color: AppColors.accentYellow,
                size: CGSize(width: 18, height: 18),
                rotation: 45,
                offset: CGSize(width: 18, height: 48)
            )

            burstPiece(
                color: AppColors.accentGreen,
                size: CGSize(width: 34, height: 10),
                rotation: 24,
                offset: CGSize(width: 50, height: 24)
            )

            burstPiece(
                color: AppColors.accentBlue,
                size: CGSize(width: 30, height: 10),
                rotation: -25,
                offset: CGSize(width: -45, height: 19)
            )

            PicktureCelebrationPhotoCard(
                fill: AppColors.accentBlue,
                showsCheckmark: false,
                isPresented: isPresented,
                rotation: -13,
                offset: CGSize(width: -17, height: 8)
            )

            PicktureCelebrationPhotoCard(
                fill: AppColors.accentGreen,
                showsCheckmark: true,
                isPresented: isPresented,
                rotation: 12,
                offset: CGSize(width: 19, height: -8)
            )
        }
        .frame(width: 128, height: 116)
        .scaleEffect(iconScale)
        .opacity(isPresented ? 1 : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("정리 완료 축하"))
    }

    private var iconScale: CGFloat {
        if reduceMotion { return isPresented ? 1 : 0.96 }
        return isPresented ? 1 : 0.72
    }

    private func burstPiece(
        color: Color,
        size: CGSize,
        rotation: Double,
        offset: CGSize,
        isCircle: Bool = false
    ) -> some View {
        let visibleOffset = isPresented || reduceMotion ? offset : .zero
        let shape = RoundedRectangle(cornerRadius: isCircle ? size.width / 2 : 3, style: .continuous)

        return shape
            .fill(color)
            .frame(width: size.width, height: size.height)
            .overlay {
                shape.strokeBorder(AppColors.border, lineWidth: 2)
            }
            .rotationEffect(.degrees(reduceMotion ? 0 : (isPresented ? rotation : 0)))
            .scaleEffect(reduceMotion ? 1 : (isPresented ? 1 : 0.35))
            .offset(x: visibleOffset.width, y: visibleOffset.height)
            .opacity(isPresented ? 1 : 0)
    }
}

private struct PicktureCelebrationPhotoCard: View {
    let fill: Color
    let showsCheckmark: Bool
    let isPresented: Bool
    let rotation: Double
    let offset: CGSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let visibleOffset = isPresented || reduceMotion ? offset : .zero
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

        shape
            .fill(fill)
            .frame(width: 68, height: 82)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(AppColors.surface.opacity(0.65))
                    .frame(width: 14, height: 14)
                    .padding(12)
            }
            .overlay {
                if showsCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(AppColors.surface)
                } else {
                    PhotoMountainGlyph()
                        .fill(AppColors.surface.opacity(0.72))
                        .frame(width: 46, height: 28)
                        .offset(y: 14)
                }
            }
            .overlay {
                shape.strokeBorder(AppColors.border, lineWidth: AppSpacing.BrutalistTokens.borderWidth)
            }
            .background {
                shape
                    .fill(AppColors.shadowColor)
                    .frame(width: 68, height: 82)
                    .offset(x: 4, y: 4)
            }
            .rotationEffect(.degrees(reduceMotion ? 0 : (isPresented ? rotation : 0)))
            .scaleEffect(reduceMotion ? 1 : (isPresented ? 1 : 0.78))
            .offset(x: visibleOffset.width, y: visibleOffset.height)
            .opacity(isPresented ? 1 : 0)
    }
}

private struct PhotoMountainGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.3, y: rect.minY + rect.height * 0.38))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY + rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.74, y: rect.minY + rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
