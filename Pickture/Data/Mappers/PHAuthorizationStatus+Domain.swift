import Photos

extension PHAuthorizationStatus {
    var toDomain: PhotoAuthorizationStatus {
        switch self {
        case .notDetermined:
            .notDetermined
        case .authorized:
            .authorized
        case .limited:
            .limited
        case .denied:
            .denied
        case .restricted:
            .restricted
        @unknown default:
            .denied
        }
    }
}
