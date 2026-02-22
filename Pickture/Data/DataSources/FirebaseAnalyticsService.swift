import Foundation

import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    nonisolated func logEvent(_ name: String, parameters: [String: any Sendable]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    nonisolated func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    nonisolated func setScreen(_ screenName: String, screenClass: String?) {
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screenName,
                AnalyticsParameterScreenClass: screenClass ?? screenName,
            ]
        )
    }
}
