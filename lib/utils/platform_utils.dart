// Conditional export — re-export the web implementation when `dart:html` is
// available, otherwise re-export the native stub so callers can access the
// same top-level getters directly from this library.
export 'platform_utils_stub.dart'
    if (dart.library.html) 'platform_utils_web.dart';

// The stub/web files provide `isWebAndroid` and `shouldShowApkButton`.
