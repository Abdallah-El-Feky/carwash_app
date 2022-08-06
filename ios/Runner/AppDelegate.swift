import UIKit
import Flutter
// import gmap
import GoogleMaps
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAoBjMXbI8k18vKn3y-wd0MuYawx4eN3GQ")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
