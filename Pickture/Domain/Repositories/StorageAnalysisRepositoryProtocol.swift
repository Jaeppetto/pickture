import Foundation

protocol StorageAnalysisRepositoryProtocol: Sendable {
    func analyzeStorage() async throws -> StorageInfo
    func getDeviceStorageInfo() async throws -> (total: Int64, used: Int64)
}
