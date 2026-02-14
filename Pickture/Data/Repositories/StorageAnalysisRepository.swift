import Foundation

final class StorageAnalysisRepository: StorageAnalysisRepositoryProtocol, @unchecked Sendable {
    init() {}

    func analyzeStorage() async throws -> StorageInfo {
        // Stub
        StorageInfo()
    }

    func getDeviceStorageInfo() async throws -> (total: Int64, used: Int64) {
        // Stub
        (total: 0, used: 0)
    }
}
