import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterAliyunPushPlugin.initKey("333548607", appSecret: "20192dafbb3245d3b754d3a26f5d8cd3");
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
