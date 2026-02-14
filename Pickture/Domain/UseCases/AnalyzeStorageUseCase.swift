import Foundation

struct AnalyzeStorageResult: Sendable {
    let storageInfo: StorageInfo
    let insights: [StorageInsight]
}

final class AnalyzeStorageUseCase: Sendable {
    private let storageRepository: any StorageAnalysisRepositoryProtocol

    init(storageRepository: any StorageAnalysisRepositoryProtocol) {
        self.storageRepository = storageRepository
    }

    func execute() async throws -> AnalyzeStorageResult {
        let info = try await storageRepository.analyzeStorage()
        let insights = generateInsights(from: info)
        return AnalyzeStorageResult(storageInfo: info, insights: insights)
    }

    private func generateInsights(from info: StorageInfo) -> [StorageInsight] {
        var insights: [StorageInsight] = []

        if info.totalScreenshotCount > 20 {
            insights.append(StorageInsight(
                title: "스크린샷 \(info.totalScreenshotCount)장",
                description: formatBytes(info.screenshotStorageBytes) + " 사용 중",
                category: .screenshots,
                suggestedFilter: .screenshotsOnly(),
                iconName: "camera.viewfinder"
            ))
        }

        if info.totalVideoCount > 5 {
            insights.append(StorageInsight(
                title: "동영상 \(info.totalVideoCount)개",
                description: formatBytes(info.videoStorageBytes) + " 사용 중",
                category: .videos,
                suggestedFilter: .videosOnly(),
                iconName: "video.fill"
            ))
        }

        let usageRatio = info.totalDeviceStorage > 0
            ? Double(info.usedDeviceStorage) / Double(info.totalDeviceStorage)
            : 0

        if usageRatio > 0.8 {
            let available = formatBytes(info.availableDeviceStorage)
            insights.append(StorageInsight(
                title: "저장 공간 부족",
                description: "남은 공간 \(available)",
                category: .general,
                iconName: "externaldrive.fill.badge.exclamationmark"
            ))
        }

        if info.totalMediaBytes > 5_000_000_000 {
            insights.append(StorageInsight(
                title: "용량 큰 파일 정리",
                description: "10MB 이상 파일을 정리해보세요",
                category: .largeFiles,
                suggestedFilter: .largeFiles(),
                iconName: "doc.fill"
            ))
        }

        if insights.isEmpty {
            insights.append(StorageInsight(
                title: "미디어 \(info.totalMediaCount)개",
                description: formatBytes(info.totalMediaBytes) + " 사용 중",
                category: .general,
                iconName: "photo.on.rectangle"
            ))
        }

        return insights
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
