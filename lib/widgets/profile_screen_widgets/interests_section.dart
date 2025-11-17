import 'package:flutter/material.dart';
//TODO : Make the inerests section responsive (no more pixel overflow )
class InterestsSection extends StatefulWidget {
  const InterestsSection({super.key, this.initialInterests = const []});

  final List<String> initialInterests;

  @override
  State<InterestsSection> createState() => _InterestsSectionState();
}

class _InterestsSectionState extends State<InterestsSection> {
  late List<String> _interests;

  @override
  void initState() {
    super.initState();
    _interests = List.of(widget.initialInterests);
  }
// Modal for adding a new interest
  Future<void> _addInterest() async {
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
      setState(() => _interests.add(result));
    }
  }
// Main build method for the interests section
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
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
            for (final interest in _interests)
              _InterestChip(label: interest),
            GestureDetector(
              onTap: _addInterest,
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
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label});

  final String label;
// Chip UI for an interest in the interests section
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
