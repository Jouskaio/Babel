import Foundation
import UniformTypeIdentifiers

/// The link in what an app shares: a URL, or text containing one.
enum SharedLink {
  static func find(in providers: [NSItemProvider]) async -> String? {
    for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      if let url = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL {
        return url.absoluteString
      }
    }
    for provider in providers
    where provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      if let text = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier)
        as? String
      {
        return text
      }
    }
    return nil
  }

  /// `babel://import?url=…`, which the app turns into its link import.
  static func babelURL(_ link: String) -> URL? {
    var components = URLComponents()
    components.scheme = "babel"
    components.host = "import"
    components.queryItems = [URLQueryItem(name: "url", value: link)]
    return components.url
  }
}
