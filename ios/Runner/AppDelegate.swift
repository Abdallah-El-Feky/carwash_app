//
import UIKit
import Flutter
import GoogleMaps
// import gmap
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

// import UIKit
// import Flutter
// import GoogleMaps // Add this line!
//
// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self.body)
//     GMSServices.provideAPIKey("AIzaSyAoBjMXbI8k18vKn3y-wd0MuYawx4eN3GQ")  // Add this line!
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

