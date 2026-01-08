import 'package:flutter/material.dart';

class SimpleTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SimpleTopBar({
    super.key,
    required this.title,
    this.onLeadingTap,
    this.onTrailingTap,
    this.leadingIcon = Icons.home,
    this.trailingIcon = Icons.tune,
  });

  final String title;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;
  final IconData leadingIcon;
  final IconData trailingIcon;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFECF0F1)
        : const Color(0xFF34495E);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onLeadingTap,
            icon: Icon(leadingIcon, color: textColor, size: 28),
            tooltip: 'Leading',
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // Only show trailing button if a handler was provided
          if (onTrailingTap != null)
            IconButton(
              onPressed: onTrailingTap,
              icon: Icon(trailingIcon, color: textColor, size: 24),
              tooltip: 'Trailing',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
