import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let apiKey = Bundle.main.object(forInfoDictionaryKey: "googleMapsApiKey") as? String

    // 3. ส่ง Key ให้ Google Maps
    GMSServices.provideAPIKey(apiKey ?? "")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
