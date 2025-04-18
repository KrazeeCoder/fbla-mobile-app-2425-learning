import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "instagram_story", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "shareToInstagramStory" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid image path", details: nil))
          return
        }

        let urlScheme = URL(string: "instagram-stories://share")!
        if UIApplication.shared.canOpenURL(urlScheme) {
          let imageURL = URL(fileURLWithPath: imagePath)
          guard let imageData = try? Data(contentsOf: imageURL) else {
            result(FlutterError(code: "IMAGE_READ_FAILED", message: "Unable to read image data", details: nil))
            return
          }

          let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData
          ]
          UIPasteboard.general.setItems([pasteboardItems], options: [:])
          UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
          result(true)
        } else {
          result(FlutterError(code: "NOT_INSTALLED", message: "Instagram is not installed", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
