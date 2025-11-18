import 'package:flutter/material.dart';
import '../common/circular_action_button.dart';

class HouseActionBar extends StatelessWidget {
  const HouseActionBar({
    super.key,
    required this.onNope,
    required this.onStar,
    required this.onLike,
    required this.onUndo,
  });

  final VoidCallback onNope;
  final VoidCallback onStar;
  final VoidCallback onLike;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SizedBox(
        height: 72,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularActionButton(
                    backgroundColor: isDark ? const Color(0xFF3F3F46) : Colors.white,
                    splashColor: Colors.red.withOpacity(0.15),
                    icon: Icons.close,
                    iconColor: Colors.red,
                    size: 56,
                    onTap: onNope,
                  ),
                  const SizedBox(width: 16),
                  CircularActionButton(
                    backgroundColor: isDark ? const Color(0xFF3F3F46) : Colors.white,
                    splashColor: Colors.blue.withOpacity(0.15),
                    icon: Icons.star,
                    iconColor: Colors.blue,
                    size: 48,
                    onTap: onStar,
                  ),
                  const SizedBox(width: 16),
                  CircularActionButton(
                    backgroundColor: isDark ? const Color(0xFF3F3F46) : Colors.white,
                    splashColor: Colors.green.withOpacity(0.15),
                    icon: Icons.favorite,
                    iconColor: Colors.green,
                    size: 56,
                    onTap: onLike,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: CircularActionButton(
                backgroundColor: isDark ? const Color(0xFF3F3F46) : Colors.white,
                splashColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                icon: Icons.undo,
                iconColor: isDark ? Colors.white70 : Colors.grey,
                size: 48,
                onTap: onUndo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
