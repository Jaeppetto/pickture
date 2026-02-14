import SwiftUI

struct DeletionQueueScreen: View {
    @State var viewModel: DeletionQueueViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
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
                    Button(viewModel.allSelected ? "선택 해제" : "전체 선택") {
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
            Button("확인") { viewModel.clearDeletionResult() }
        } message: {
            if let result = viewModel.deletionResult {
                Text("\(result.deletedCount)개 항목이 삭제되었습니다.\n\(result.freedBytes.formattedBytes) 확보")
            }
        }
    }

    // MARK: - Grid

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.trashItems) { item in
                    gridCell(for: item)
                }
            }
        }
    }

    private func gridCell(for item: TrashItem) -> some View {
        let isSelected = viewModel.selectedIds.contains(item.id)

        return Button {
            viewModel.toggleSelection(id: item.id)
        } label: {
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
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                    }
                }
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? AppColors.primary : .white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(4)
                }
                .overlay(alignment: .bottomTrailing) {
                    Text(item.fileSize.formattedBytesShort)
                        .font(AppTypography.monoCaption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(4)
                }
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(AppColors.primary, lineWidth: 3)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: AppSpacing.xs) {
            if viewModel.hasSelection {
                Text("\(viewModel.selectedIds.count)개 선택 (\(viewModel.totalSelectedBytes.formattedBytes))")
                    .font(AppTypography.footnoteMedium)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: AppSpacing.sm) {
                Button {
                    Task { await viewModel.restoreSelected() }
                } label: {
                    Text("복원")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
                        .cardShadow()
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
                    Text(viewModel.hasSelection ? "선택 삭제" : "전체 삭제")
                        .glassDestructiveButton()
                }
                .disabled(viewModel.isDeleting)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "trash.slash")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.textSecondary)

            Text("삭제 대기열이 비어있습니다")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.textPrimary)

            Text("정리 시 삭제한 사진이 여기에 표시됩니다")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
