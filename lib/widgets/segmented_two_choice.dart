import 'package:flutter/material.dart';

class SegmentedTwoChoice extends StatelessWidget {
  const SegmentedTwoChoice({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedIndex,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final int selectedIndex; // 0 or 1
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildItem(context, label: leftLabel, index: 0, activeColor: activeColor),
          _buildItem(context, label: rightLabel, index: 1, activeColor: activeColor),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required String label, required int index, required Color activeColor}) {
    final bool isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
