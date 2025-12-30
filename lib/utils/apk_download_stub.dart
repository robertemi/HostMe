import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fallback implementation for non-web platforms — open the URL with
/// the platform's default handler (external browser).
Future<void> openApkUrl(String url, BuildContext context) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link invalid.')));
    return;
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open APK link.')));
  }
}
