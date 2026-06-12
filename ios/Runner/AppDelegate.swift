import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // UIScene lifecycle: plugin registration moves here from
  // didFinishLaunchingWithOptions. See
  // https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for firebase_messaging to deliver notifications to the
    // foreground-message listener on Dart side and to invoke the
    // app-opened-from-notification handler when the user taps an OS
    // notification. FlutterAppDelegate already conforms to
    // UNUserNotificationCenterDelegate (Flutter installs the protocol
    // implementation at the engine level), so all we need is to register
    // ourselves as the delegate at launch. Without this, FCM messages
    // arrive at the iOS layer but never reach the Flutter onMessage
    // listener and `onMessageOpenedApp` is silently ignored.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
