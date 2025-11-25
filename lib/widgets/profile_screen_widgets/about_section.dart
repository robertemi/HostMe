import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({
    super.key,
    required this.occupation,
  });

  final String? occupation; // stored lowercase in model

  String _displayOccupation() {
    if (occupation == null || occupation!.isEmpty) return 'Not specified';
    final o = occupation!;
    return o[0].toUpperCase() + o.substring(1); // simple capitalize
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Occupation: ${_displayOccupation()}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
