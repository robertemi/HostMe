import 'package:flutter/material.dart';

class InterestsSection extends StatelessWidget {
  const InterestsSection({
    super.key,
    required this.interests,
    required this.onChanged,
  });

  final List<String> interests;
  final ValueChanged<List<String>> onChanged;

  // Modal for adding a new interest
  Future<void> _addInterest(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add interest'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Cooking'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      if (!interests.contains(result)) {
        onChanged([...interests, result]);
      }
    }
  }

  // Main build method for the interests section
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Interests',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Interests chips and add button
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in interests)
                _InterestChip(
                  label: interest,
                  onRemove: () {
                    final newList = List<String>.from(interests)..remove(interest);
                    onChanged(newList);
                  },
                ),
              GestureDetector(
                onTap: () => _addInterest(context),
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
                        style: TextStyle( color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
// Chip UI for an interest in the interests section
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
