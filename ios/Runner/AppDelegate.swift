import Flutter
import UIKit
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  static var tokenChannel: FlutterMethodChannel?
  static var latestToken: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyColsmVMTmRinysKMmpW-i8YptrsyEqDhY")

    // Request notification permission for iOS local notifications
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { granted, error in
      if granted {
        print("DEBUG [iOS]: Notification permission granted")
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      } else {
        print("DEBUG [iOS]: Notification permission denied: \(String(describing: error))")
      }
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
        let tokenChannel = FlutterMethodChannel(name: "com.nsapp/notifications",
                                                  binaryMessenger: controller.binaryMessenger)
        AppDelegate.tokenChannel = tokenChannel
        
        tokenChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getLatestToken" {
                result(AppDelegate.latestToken)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }

    return result
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    debugPrint("DEBUG [iOS]: Native APNs Token: \(token)")
    
    // Store token for future retrieval
    AppDelegate.latestToken = token
    
    // Send token to Flutter immediately
    AppDelegate.tokenChannel?.invokeMethod("onTokenReceived", arguments: token)
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    debugPrint("DEBUG [iOS]: Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
