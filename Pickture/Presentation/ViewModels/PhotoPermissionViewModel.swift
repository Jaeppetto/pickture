import Foundation
import SwiftUI

@Observable
@MainActor
final class PhotoPermissionViewModel {
    private(set) var authorizationStatus: PhotoAuthorizationStatus = .notDetermined
    private(set) var isRequesting = false

    private let photoRepository: any PhotoRepositoryProtocol

    init(photoRepository: any PhotoRepositoryProtocol) {
        self.photoRepository = photoRepository
        self.authorizationStatus = photoRepository.checkAuthorizationStatus()
    }

    var hasFullAccess: Bool {
        authorizationStatus == .authorized
    }

    var hasLimitedAccess: Bool {
        authorizationStatus == .limited
    }

    var hasAnyAccess: Bool {
        hasFullAccess || hasLimitedAccess
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    func requestPermission() async {
        guard !isRequesting else { return }
        isRequesting = true
        defer { isRequesting = false }

        authorizationStatus = await photoRepository.requestAuthorization()
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
