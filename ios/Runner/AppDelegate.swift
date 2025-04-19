import UIKit
import Flutter
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  let facebookAppID = "670076459305709"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    print("✅ AppDelegate: didFinishLaunchingWithOptions called")

    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("✅ Facebook SDK initialized")

    // Method channel setup
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "instagram_story", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }

      print("📣 Flutter call received: \(call.method)")

      if call.method == "shareToInstagramStory" {
        guard let args = call.arguments as? [String: Any],
              let backgroundPath = args["backgroundImagePath"] as? String,
              let stickerPath = args["stickerImagePath"] as? String else {
          print("❌ Missing image paths")
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing image paths", details: nil))
          return
        }

        self.shareToInstagram(backgroundImagePath: backgroundPath, stickerImagePath: stickerPath)
        result(true)
      } else {
        print("⚠️ Unknown method: \(call.method)")
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

 private func shareToInstagram(backgroundImagePath: String, stickerImagePath: String) {
    print("📸 Preparing to share background: \(backgroundImagePath) + sticker: \(stickerImagePath)")

    guard let backgroundImage = UIImage(contentsOfFile: backgroundImagePath),
          let stickerImage = UIImage(contentsOfFile: stickerImagePath),
          let stickerData = stickerImage.pngData() else {
      print("❌ Failed to load or convert image files")
      return
    }

    // ✅ backgroundImage loaded but not used in pasteboardItems
    _ = backgroundImage.pngData() // keep variable to avoid unused warning

    let pasteboardItems: [[String: Any]] = [[
      // "com.instagram.sharedSticker.backgroundImage": backgroundData,  <-- commented out for now
      "com.instagram.sharedSticker.stickerImage": stickerData,
      "com.instagram.sharedSticker.backgroundTopColor": "#444444",
      "com.instagram.sharedSticker.backgroundBottomColor": "#222222"
    ]]

    let options: [UIPasteboard.OptionsKey: Any] = [
      .expirationDate: Date().addingTimeInterval(60 * 5)
    ]

    UIPasteboard.general.setItems(pasteboardItems, options: options)

    let urlString = "instagram-stories://share?source_application=\(facebookAppID)"
    guard let urlScheme = URL(string: urlString),
          UIApplication.shared.canOpenURL(urlScheme) else {
      print("❌ Instagram not installed or URL scheme failed")
      return
    }

    UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
    print("📤 Instagram story with sticker + background colors triggered")
}


  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    print("🌐 AppDelegate: openURL called with URL: \(url)")
    return ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[.sourceApplication] as? String,
      annotation: options[.annotation]
    )
  }
}
