import Cocoa

/// "Share → Babel" from Safari or any app: opens Babel's link import with the shared link.
final class ShareViewController: NSViewController {
  override func loadView() {
    view = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    Task { await share() }
  }

  private func share() async {
    let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
    if let link = await SharedLink.find(in: items.flatMap { $0.attachments ?? [] }),
      let target = SharedLink.babelURL(link)
    {
      NSWorkspace.shared.open(target)
    }
    extensionContext?.completeRequest(returningItems: nil)
  }
}
