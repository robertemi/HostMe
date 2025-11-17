import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  const CircularActionButton({
    super.key,
    required this.backgroundColor,
    required this.splashColor,
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.onTap,
    this.elevation = 2,
  });

  final Color backgroundColor;
  final Color splashColor;
  final IconData icon;
  final Color iconColor;
  final double size;
  final double elevation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: elevation,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: splashColor,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: size * 0.48),
        ),
      ),
    );
  }
}
