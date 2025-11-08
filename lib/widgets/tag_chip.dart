import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.darkBackground = false});
  final String label;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    final bg = darkBackground ? Colors.white.withOpacity(0.2) : Colors.black12;
    final fg = darkBackground ? Colors.white : Colors.black87;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
