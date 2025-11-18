import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassBanner extends StatelessWidget {
  const GlassBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.background,
    required this.iconColor,
    this.actionLabel,
    this.onAction,
    this.titleColor,
    this.messageColor,
    this.surfaceOpacity,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color background;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? titleColor;
  final Color? messageColor;
  final double? surfaceOpacity;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: theme.cardColor.withOpacity(surfaceOpacity ?? 0.95),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  // subtle border to separate from background when needed
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? background.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: titleColor ?? theme.colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: messageColor ?? theme.colorScheme.onSurface.withOpacity(0.9))),
                      ],
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 8),
                    TextButton(onPressed: onAction, child: Text(actionLabel!, style: TextStyle(color: theme.colorScheme.primary))),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
