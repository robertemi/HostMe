import 'package:flutter/material.dart';

class LabeledSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final List<String> labels;

  const LabeledSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final index = value.round().clamp(1, labels.length) - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          value: value.clamp(min, max),
          onChanged: onChanged,
          label: labels[index],
        ),
        Text(
          labels[index],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
