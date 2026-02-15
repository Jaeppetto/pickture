import Foundation

enum AppConstants {
    static let appName = "Pickture"
    static let bundleId = "com.jaeppetto.pickture"

    enum Trash {
        static let retentionDays = 30
    }

    enum Cleaning {
        static let comboThreshold = 5
    }

    enum Photo {
        static let thumbnailSize = CGSize(width: 200, height: 200)
        static let previewSize = CGSize(width: 800, height: 800)
        static let largeFileSizeThreshold: Int64 = 10_485_760  // 10MB
        static let pageSize = 50
    }

    enum Animation {
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
        static let quickDuration: Double = 0.2
        static let standardDuration: Double = 0.3
    }
}
