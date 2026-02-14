import SwiftUI

struct PhotoStartPickerView: View {
    let photoRepository: any PhotoRepositoryProtocol
    let onSelected: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var photos: [Photo] = []
    @State private var thumbnails: [String: UIImage] = [:]
    @State private var isLoading = false
    @State private var hasMore = true

    private let pageSize = 100
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        gridCell(photo: photo, index: index)
                            .onAppear {
                                if index == photos.count - 20 && hasMore {
                                    Task { await loadMore() }
                                }
                            }
                    }

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle("시작 위치 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
        .task {
            await loadMore()
        }
    }

    // MARK: - Grid Cell

    private func gridCell(photo: Photo, index: Int) -> some View {
        Button {
            onSelected(index)
            dismiss()
        } label: {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let thumbnail = thumbnails[photo.id] {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(AppColors.surface)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .clipped()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Loading

    private func loadMore() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let offset = photos.count
            let newPhotos = try await photoRepository.fetchPhotos(
                offset: offset, limit: pageSize, filter: nil
            )

            if newPhotos.count < pageSize { hasMore = false }
            photos.append(contentsOf: newPhotos)

            let size = AppConstants.Photo.thumbnailSize
            for photo in newPhotos {
                if let image = await photoRepository.requestThumbnail(for: photo.id, size: size) {
                    thumbnails[photo.id] = image
                }
            }
        } catch {
            hasMore = false
        }
    }
}
