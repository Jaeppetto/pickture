import SwiftUI
import Charts

struct StorageChartView: View {
    let storageInfo: StorageInfo

    private var chartData: [StorageCategory] {
        [
            StorageCategory(name: "사진", bytes: storageInfo.photoStorageBytes, color: AppColors.primary),
            StorageCategory(name: "동영상", bytes: storageInfo.videoStorageBytes, color: Color(hex: 0x7C3AED)),
            StorageCategory(name: "스크린샷", bytes: storageInfo.screenshotStorageBytes, color: Color(hex: 0xFF9500)),
            StorageCategory(name: "기타", bytes: storageInfo.otherMediaBytes, color: AppColors.textSecondary),
        ].filter { $0.bytes > 0 }
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Chart(chartData) { item in
                    SectorMark(
                        angle: .value("Size", item.bytes),
                        innerRadius: .ratio(0.65),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
                .frame(height: 180)

                VStack(spacing: AppSpacing.xxs) {
                    Text(storageInfo.totalMediaBytes.formattedBytesShort)
                        .font(AppTypography.title3)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("미디어 총 용량")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppSpacing.md) {
                ForEach(chartData) { item in
                    HStack(spacing: AppSpacing.xxs) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.name)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}

private struct StorageCategory: Identifiable {
    let id = UUID()
    let name: String
    let bytes: Int64
    let color: Color
}
