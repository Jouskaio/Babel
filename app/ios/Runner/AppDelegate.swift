import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var shareInbox: ShareInbox?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "BabelShareInbox") {
      shareInbox = ShareInbox(messenger: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// `babel://import?url=…` from the share extension, or a book opened with Babel.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if shareInbox?.receive(url) == true { return true }
    return super.application(app, open: url, options: options)
  }
}
