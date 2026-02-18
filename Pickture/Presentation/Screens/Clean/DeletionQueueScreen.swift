import SwiftUI

struct DeletionQueueScreen: View {
    @State var viewModel: DeletionQueueViewModel
    let onDeletionCompleted: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    private let columns = [
        GridItem(.adaptive(minimum: 104, maximum: 160), spacing: AppSpacing.xs),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.trashItems.isEmpty {
                    emptyState
                } else {
                    gridContent
                }

                if !viewModel.trashItems.isEmpty {
                    bottomBar
                }
            }
            .background(AppColors.background)
            .navigationTitle("삭제 대기열")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(selectAllButtonTitle) {
                        viewModel.selectAll()
                    }
                    .font(AppTypography.bodyMedium)
                }
            }
        }
        .task {
            await viewModel.loadTrashItems()
        }
        .alert("삭제 완료", isPresented: .init(
            get: { viewModel.deletionResult != nil },
            set: { if !$0 { viewModel.clearDeletionResult() } }
        )) {
            Button("확인") {
                viewModel.clearDeletionResult()
                onDeletionCompleted()
                dismiss()
            }
        } message: {
            if let result = viewModel.deletionResult {
                Text("\(result.deletedCount)개 항목이 삭제되었습니다.\n\(result.freedBytes.formattedBytes) 확보")
            }
        }
    }

    // MARK: - Grid

    private var gridContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                summaryHeader

                LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
                    ForEach(viewModel.trashItems) { item in
                        gridCell(for: item)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private func gridCell(for item: TrashItem) -> some View {
        let isSelected = viewModel.selectedIds.contains(item.id)
        let shape = RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadius, style: .continuous)

        return Button {
            viewModel.toggleSelection(id: item.id)
        } label: {
            ZStack(alignment: .topTrailing) {
                Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let thumbnail = viewModel.thumbnails[item.photoId] {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(AppColors.surface)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(AppColors.inkMuted)
                            }
                    }
                }
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }
                .clipped()

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(deletedLabel(for: item))
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(.white)
                    Text(item.fileSize.formattedBytesShort)
                        .font(AppTypography.monoCaption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.xs)
                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                .allowsHitTesting(false)

                HStack(spacing: AppSpacing.xxs) {
                    expirationBadge(for: item)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? AppColors.accentYellow : .white.opacity(0.92))
                }
                .padding(AppSpacing.xs)
            }
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(
                    AppColors.border,
                    lineWidth: isSelected ? AppSpacing.BrutalistTokens.borderWidthThick : 2
                )
            }
            .background(
                isSelected
                    ? AnyView(
                        shape
                            .fill(AppColors.accentYellow)
                            .offset(x: AppSpacing.BrutalistTokens.shadowOffset, y: AppSpacing.BrutalistTokens.shadowOffset)
                    )
                    : AnyView(EmptyView())
            )
            .overlay(alignment: .topLeading) {
                if isSelected {
                    Text("선택됨")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(AppColors.ink)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(AppColors.accentYellow)
                        .overlay {
                            Rectangle().strokeBorder(AppColors.border, lineWidth: 1)
                        }
                        .padding(AppSpacing.xs)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
    }

    private func expirationBadge(for item: TrashItem) -> some View {
        let days = daysUntilExpiration(for: item)
        let badgeColor: Color = days <= 1 ? AppColors.accentRed : (days <= 3 ? AppColors.accentYellow : AppColors.surface)
        let textColor: Color = days <= 1 ? .white : AppColors.ink

        return Text(expirationLabel(for: item))
            .font(AppTypography.captionSmall)
            .foregroundStyle(textColor)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xxs)
            .background(badgeColor)
            .overlay {
                Rectangle().strokeBorder(AppColors.border, lineWidth: 1)
            }
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("삭제 대기 사진 \(viewModel.trashItems.count)개")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.ink)

            HStack {
                Label("예상 확보", systemImage: "internaldrive")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.inkMuted)
                Spacer()
                Text(totalQueueBytes.formattedBytes)
                    .font(AppTypography.monoBody)
                    .foregroundStyle(AppColors.ink)
            }

            if nearExpirationCount > 0 {
                Text("곧 만료: \(nearExpirationCount)개")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(AppColors.accentRed)
            }
        }
        .padding(AppSpacing.md)
        .brutalistCard()
    }

    private var totalQueueBytes: Int64 {
        viewModel.trashItems.reduce(0) { $0 + $1.fileSize }
    }

    private var nearExpirationCount: Int {
        viewModel.trashItems.filter { daysUntilExpiration(for: $0) <= 3 }.count
    }

    private func daysUntilExpiration(for item: TrashItem) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: item.expiresAt)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private func expirationLabel(for item: TrashItem) -> String {
        let days = daysUntilExpiration(for: item)
        if days <= 0 { return String(localized: "오늘 만료", locale: locale) }
        let format = String(localized: "%@일 남음", locale: locale)
        return String(format: format, locale: locale, String(days))
    }

    private func deletedLabel(for item: TrashItem) -> String {
        let days = max(
            0,
            Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: item.deletedAt),
                to: Calendar.current.startOfDay(for: .now)
            ).day ?? 0
        )

        if days == 0 { return String(localized: "오늘 삭제됨", locale: locale) }
        let format = String(localized: "%@일 전 삭제", locale: locale)
        return String(format: format, locale: locale, String(days))
    }

    private var selectAllButtonTitle: LocalizedStringKey {
        viewModel.allSelected ? "선택 해제" : "전체 선택"
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: AppSpacing.xs) {
            if viewModel.hasSelection {
                Text("\(viewModel.selectedIds.count)개 선택 (\(viewModel.totalSelectedBytes.formattedBytes))")
                    .font(AppTypography.footnoteMedium)
                    .foregroundStyle(AppColors.inkMuted)
            } else {
                Text("복원하거나 완전 삭제할 항목을 선택하세요")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.inkMuted)
            }

            HStack(spacing: AppSpacing.sm) {
                Button {
                    Task { await viewModel.restoreSelected() }
                } label: {
                    Text("복원")
                        .brutalistSecondaryButton()
                }
                .disabled(!viewModel.hasSelection)
                .opacity(viewModel.hasSelection ? 1 : 0.5)

                Button {
                    Task {
                        if viewModel.hasSelection {
                            await viewModel.deleteSelected()
                        } else {
                            await viewModel.deleteAll()
                        }
                    }
                } label: {
                    Text(viewModel.hasSelection ? LocalizedStringKey("선택 삭제") : LocalizedStringKey("전체 삭제"))
                        .brutalistDestructiveButton()
                }
                .disabled(viewModel.isDeleting)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.border)
                .frame(height: AppSpacing.BrutalistTokens.borderWidth)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "trash.slash")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.inkMuted)

            Text("삭제 대기열이 비어있습니다")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.ink)

            Text("정리 시 삭제한 사진이 여기에 표시됩니다")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
