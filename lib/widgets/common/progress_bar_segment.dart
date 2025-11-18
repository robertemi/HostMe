import 'package:flutter/material.dart';

class ProgressBarSegment extends StatelessWidget {
  const ProgressBarSegment({super.key, required this.filled, this.dimmed = false});

  final double filled; // 0..1
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final base = dimmed ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.8);
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 4,
          value: filled,
          backgroundColor: base.withOpacity(0.35),
          valueColor: AlwaysStoppedAnimation<Color>(base),
        ),
      ),
    );
  }
}
