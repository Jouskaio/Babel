/// Where downloaded book files go: the app's storage on devices, a browser download on the web.
library;

export 'save_file_io.dart' if (dart.library.js_interop) 'save_file_web.dart';
