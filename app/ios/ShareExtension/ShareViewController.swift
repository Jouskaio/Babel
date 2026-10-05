import UIKit
import UniformTypeIdentifiers

/// "Share → Babel" from Safari or any app: opens Babel's link import with the shared link.
final class ShareViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { await share() }
  }

  private func share() async {
    let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
    if let link = await SharedLink.find(in: items.flatMap { $0.attachments ?? [] }),
      let target = SharedLink.babelURL(link)
    {
      open(target)
    }
    extensionContext?.completeRequest(returningItems: nil)
  }

  /// Extensions cannot use UIApplication.shared: reach the application through the
  /// responder chain to open Babel.
  private func open(_ url: URL) {
    typealias Open = @convention(c) (
      AnyObject, Selector, URL, [UIApplication.OpenExternalURLOptionsKey: Any],
      ((Bool) -> Void)?
    ) -> Void
    let selector = NSSelectorFromString("openURL:options:completionHandler:")
    var responder: UIResponder? = self
    while let current = responder {
      if current is UIApplication, current.responds(to: selector) {
        let method = unsafeBitCast(current.method(for: selector), to: Open.self)
        method(current, selector, url, [:], nil)
        return
      }
      responder = current.next
    }
  }
}
