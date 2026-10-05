import FlutterMacOS
import Foundation

/// Hands links and book files given to Babel to Flutter on the `babel/share` channel:
/// `babel://import?url=…` (from the share extension) and files opened with Babel.
final class ShareInbox {
  private let channel: FlutterMethodChannel
  private var pending: [String: String]?
  private var flutterReady = false

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "babel/share", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "initial" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.flutterReady = true
      result(self.pending)
      self.pending = nil
    }
  }

  /// Whether the URL was for Babel.
  func receive(_ url: URL) -> Bool {
    if url.scheme == "babel" {
      let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
      guard let link = items?.first(where: { $0.name == "url" })?.value else { return false }
      deliver(["text": link])
      return true
    }
    guard url.isFileURL, let copy = ShareInbox.copy(url) else { return false }
    deliver(["file": copy.path])
    return true
  }

  private func deliver(_ share: [String: String]) {
    if flutterReady {
      channel.invokeMethod("shared", arguments: share)
    } else {
      pending = share
    }
  }

  /// Copies the file into the app's temporary folder; only the latest one is kept.
  static func copy(_ url: URL) -> URL? {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    let files = FileManager.default
    let folder = files.temporaryDirectory.appendingPathComponent("shared", isDirectory: true)
    try? files.removeItem(at: folder)
    do {
      try files.createDirectory(at: folder, withIntermediateDirectories: true)
      let target = folder.appendingPathComponent(url.lastPathComponent)
      try files.copyItem(at: url, to: target)
      return target
    } catch {
      return nil
    }
  }
}
