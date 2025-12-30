import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/feedback_config.dart';

class FeedbackService {
  static const _shownKey = 'feedback_popup_shown';
  static bool _scheduled = false;

  /// Call to potentially show the feedback popup. Will show at most once per
  /// user (persisted in SharedPreferences) unless the user chose "Remind me".
  static Future<void> maybeShowFeedbackPopup(BuildContext context, {String? userId}) async {
    if (_scheduled) return;
    _scheduled = true;

    final prefs = await SharedPreferences.getInstance();
    final key = userId != null ? '${_shownKey}_$userId' : _shownKey;
    final shown = prefs.getBool(key) ?? false;
    if (shown) return;

    // Schedule after current frame to avoid build-time dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final res = await showDialog<String>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.72),
        builder: (_) => AlertDialog(
          title: const Text('Can you help us with a feedback?'),
          content: const Text('It takes ~5 minutes. Your feedback helps us with the project and evaluation.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 'later'), child: const Text('Remind me later')),
            TextButton(onPressed: () => Navigator.pop(context, 'no'), child: const Text('No, thanks')),
            ElevatedButton(onPressed: () => Navigator.pop(context, 'yes'), child: const Text('Give feedback')),
          ],
        ),
      );

      if (res == 'yes') {
        await _openFeedbackLink();
        await prefs.setBool(key, true);
      } else if (res == 'no') {
        await prefs.setBool(key, true);
      } else {
        // remind later: clear the scheduled flag so we may show again later
        _scheduled = false;
      }
    });
  }

  /// Show the feedback popup at login time. This will always display (once
  /// per login) unless the user previously selected "No, thanks" which will
  /// suppress future prompts (persisted per user).
  static Future<void> showFeedbackPopupOnLogin(BuildContext context, {required String userId}) async {
    // Do not show if user previously opted out
    final prefs = await SharedPreferences.getInstance();
    final key = '${_shownKey}_$userId';
    final optedOut = prefs.getBool(key) ?? false;
    if (optedOut) return;

    // Show the dialog immediately
    final res = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => AlertDialog(
        title: const Text('Ne ajuți cu un feedback?'),
        content: const Text('Durează ~5 minute. Feedback‑ul ne ajută pentru proiect și evaluare.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'later'), child: const Text('Remind me later')),
          TextButton(onPressed: () => Navigator.pop(context, 'no'), child: const Text('No, thanks')),
          ElevatedButton(onPressed: () => Navigator.pop(context, 'yes'), child: const Text('Give feedback')),
        ],
      ),
    );

    if (res == 'yes') {
      await _openFeedbackLink();
      // do not persist so it will show again on next login
    } else if (res == 'no') {
      // user opted out: persist the opt-out for this user
      await prefs.setBool(key, true);
    } else {
      // remind me later: do nothing; will show again next login
    }
  }

  static Future<void> _openFeedbackLink() async {
    final uri = Uri.parse(kFeedbackFormUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // If launching fails, do nothing for now; could show an error later.
    }
  }

  /// Public helper to open the feedback form (used by profile button etc.).
  static Future<void> openFeedbackForm() async => _openFeedbackLink();
}
