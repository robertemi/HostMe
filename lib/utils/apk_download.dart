// Conditional import: use the web implementation when `dart:html` is available,
// otherwise use the stub that opens the URL via `url_launcher`.

// Re-exports the platform-specific implementation:
export 'apk_download_stub.dart'
    if (dart.library.html) 'apk_download_web.dart';
