import SwiftUI
import Charts

struct StorageChartView: View {
    let storageInfo: StorageInfo

    private var chartData: [StorageCategory] {
        [
            StorageCategory(name: "사진", bytes: storageInfo.photoStorageBytes, color: AppColors.chartPhoto),
            StorageCategory(name: "동영상", bytes: storageInfo.videoStorageBytes, color: AppColors.chartVideo),
            StorageCategory(name: "스크린샷", bytes: storageInfo.screenshotStorageBytes, color: AppColors.chartScreenshot),
            StorageCategory(name: "기타", bytes: storageInfo.otherMediaBytes, color: AppColors.chartOther),
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
                }
                .frame(height: 180)

                VStack(spacing: AppSpacing.xxs) {
                    Text(storageInfo.totalMediaBytes.formattedBytesShort)
                        .font(AppTypography.monoTitle)
                        .foregroundStyle(AppColors.ink)
                    Text("미디어 총 용량")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.inkMuted)
                }
            }

            HStack(spacing: AppSpacing.sm) {
                ForEach(chartData) { item in
                    HStack(spacing: AppSpacing.xxs) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(item.color)
                            .overlay {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(AppColors.border, lineWidth: 1)
                            }
                            .frame(width: 14, height: 14)
                        Text(item.name)
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(AppColors.ink)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(
                        RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall)
                            .fill(item.color.opacity(0.15))
                            .overlay {
                                RoundedRectangle(cornerRadius: AppSpacing.BrutalistTokens.cornerRadiusSmall)
                                    .strokeBorder(AppColors.border, lineWidth: 1)
                            }
                    )
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
