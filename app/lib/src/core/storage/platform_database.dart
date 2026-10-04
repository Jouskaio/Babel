/// The sembast database factory of the platform: files on devices, IndexedDB on the web.
library;

export 'platform_database_io.dart'
    if (dart.library.js_interop) 'platform_database_web.dart';
