import 'package:flutter/material.dart';
// Web-only: use dart:html to trigger a download without navigating away.
import 'dart:html' as html;

Future<void> openApkUrl(String url, BuildContext context) async {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'hostme.apk')
    ..click();
  // No further action required on web.
  return anchor.onClick.first.then((_) {});
}
