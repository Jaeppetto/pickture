import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let storageChannel = FlutterMethodChannel(
      name: "com.jaeppetto.pickture/storage",
      binaryMessenger: controller.binaryMessenger
    )

    storageChannel.setMethodCallHandler { (call, result) in
      if call.method == "getStorageInfo" {
        do {
          let attrs = try FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
          )
          let totalBytes = (attrs[.systemSize] as? Int64) ?? 0
          let freeBytes = (attrs[.systemFreeSize] as? Int64) ?? 0
          result([
            "totalBytes": totalBytes,
            "freeBytes": freeBytes,
          ])
        } catch {
          result(FlutterError(
            code: "STORAGE_ERROR",
            message: error.localizedDescription,
            details: nil
          ))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
