import 'package:flutter/material.dart';
import '../utils/notifications.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fallback implementation for non-web platforms — open the URL with
/// the platform's default handler (external browser).
Future<void> openApkUrl(String url, BuildContext context) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    await showAppError(context, 'Link invalid.');
    return;
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    await showAppError(context, 'Unable to open APK link.');
  }
}
