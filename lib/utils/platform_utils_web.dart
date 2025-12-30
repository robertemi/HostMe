import 'dart:html' as html;

bool get isWebAndroid {
  final ua = (html.window.navigator.userAgent ?? '').toLowerCase();
  return ua.contains('android');
}

bool get shouldShowApkButton {
  if (isWebAndroid) return true;
  final params = Uri.base.queryParameters;
  return params['showApk'] == '1';
}
