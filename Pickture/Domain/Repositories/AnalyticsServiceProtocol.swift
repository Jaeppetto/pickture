import Foundation

protocol AnalyticsServiceProtocol: Sendable {
    func logEvent(_ name: String, parameters: [String: any Sendable]?)
    func setUserProperty(_ value: String?, forName name: String)
    func setScreen(_ screenName: String, screenClass: String?)
}
