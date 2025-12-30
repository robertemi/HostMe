import 'package:flutter/material.dart';

class RoommateActionBar extends StatelessWidget {
  const RoommateActionBar({
    super.key,
    required this.onNope,
    required this.onLike,
  });

  final VoidCallback onNope;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF334155) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionColumnButton(
            label: 'Nope',
            icon: Icons.close,
            iconSize: 28,
            color: Colors.red.shade600,
            surface: surface,
            padding: const EdgeInsets.all(16),
            onTap: onNope,
          ),
          _ActionColumnButton(
            label: 'Like',
            icon: Icons.favorite,
            iconSize: 28,
            color: theme.primaryColor,
            surface: surface,
            padding: const EdgeInsets.all(16),
            onTap: onLike,
          ),
        ],
      ),
    );
  }
}

class _ActionColumnButton extends StatelessWidget {
  const _ActionColumnButton({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.surface,
    required this.padding,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final Color color;
  final Color surface;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: surface,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: Icon(icon, color: color, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
