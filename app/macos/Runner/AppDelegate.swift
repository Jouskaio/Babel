import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Set by the main window once Flutter runs.
  var shareInbox: ShareInbox? {
    didSet {
      for url in early { _ = shareInbox?.receive(url) }
      early.removeAll()
    }
  }
  private var early: [URL] = []

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// `babel://import?url=…` from the share extension, or books opened with Babel.
  override func application(_ application: NSApplication, open urls: [URL]) {
    guard let inbox = shareInbox else {
      early.append(contentsOf: urls)
      return
    }
    for url in urls { _ = inbox.receive(url) }
  }
}
