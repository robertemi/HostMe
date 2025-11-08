import 'package:flutter/material.dart';

class InterestsSection extends StatelessWidget {
  const InterestsSection({
    super.key,
    required this.interests,
    required this.highlighted,
    this.onAdd,
  });

  final List<String> interests;
  final Set<String> highlighted; // which interests should use primary styling
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final interest in interests)
              _InterestChip(
                label: interest,
                highlighted: highlighted.contains(interest),
              ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white54, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, size: 18, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: highlighted ? primary.withOpacity(0.25) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: highlighted ? primary : Colors.white,
          fontSize: 13,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }
}
