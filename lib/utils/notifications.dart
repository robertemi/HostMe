import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/glass_banner.dart';

/// Show an animated overlay banner from the top-center. The banner fades and
/// slides in from slightly above, and is dismissed after [duration] or when
/// [dismiss] is called. The visual is transparent with white text by default.
Future<void> showAppBanner(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required Color accentColor,
  required Color iconColor,
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onAction,
  String? actionLabel,
}) async {
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(builder: (ctx) {
    return _AnimatedBannerOverlay(
      icon: icon,
      title: title,
      message: message,
      accentColor: accentColor,
      iconColor: iconColor,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  });

  overlay.insert(entry);

  // Auto-dismiss after duration
  Timer(duration, () {
    if (!entry.mounted) return;
    entry.remove();
  });
}

Future<void> showAppError(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction, Duration duration = const Duration(seconds: 4)}) async {
  await showAppBanner(
    context,
    icon: Icons.error_outline,
    title: 'Error',
    message: message,
    accentColor: Theme.of(context).colorScheme.error,
    iconColor: Theme.of(context).colorScheme.onError,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );
}

Future<void> showAppSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) async {
  await showAppBanner(
    context,
    icon: Icons.check_circle_outline,
    title: 'Success',
    message: message,
    accentColor: Theme.of(context).colorScheme.primary,
    iconColor: Theme.of(context).colorScheme.onPrimary,
    duration: duration,
  );
}

class _AnimatedBannerOverlay extends StatefulWidget {
  const _AnimatedBannerOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.accentColor,
    required this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color accentColor;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_AnimatedBannerOverlay> createState() => _AnimatedBannerOverlayState();
}

class _AnimatedBannerOverlayState extends State<_AnimatedBannerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final Animation<double> _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, -0.18), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  late final Animation<double> _scale = Tween(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: SafeArea(
        top: true,
        child: Center(
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width * 0.9),
                  child: GlassBanner(
                    icon: widget.icon,
                    title: widget.title,
                    message: widget.message,
                    background: widget.accentColor,
                    iconColor: widget.iconColor,
                    titleColor: Colors.white,
                    messageColor: Colors.white,
                    surfaceOpacity: 0.06, // subtle frosted surface
                    iconBackgroundColor: Colors.white.withOpacity(0.06),
                    actionLabel: widget.actionLabel,
                    onAction: widget.onAction,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
