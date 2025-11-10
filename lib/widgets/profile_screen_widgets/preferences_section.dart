import 'package:flutter/material.dart';

class PreferencesSection extends StatelessWidget {
  final double cleanlinessLevel;
  final ValueChanged<double> onCleanlinessChanged;
  final double noiseLevel;
  final ValueChanged<double> onNoiseChanged;
  final double budgetLevel;
  final ValueChanged<double> onBudgetChanged;
  final bool smoking;
  final ValueChanged<bool> onSmokingChanged;
  final bool pets;
  final ValueChanged<bool> onPetsChanged;

  const PreferencesSection({
    super.key,
    required this.cleanlinessLevel,
    required this.onCleanlinessChanged,
    required this.noiseLevel,
    required this.onNoiseChanged,
    required this.budgetLevel,
    required this.onBudgetChanged,
    required this.smoking,
    required this.onSmokingChanged,
    required this.pets,
    required this.onPetsChanged
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Budget slider
            const Text('Budget'),
            _LabeledSlider(
              min: 1,
              max: 5,
              value: budgetLevel,
              onChanged: onBudgetChanged,
              labels: const [
                'Under \$500',
                '\$500-\$800',
                '\$800-\$1000',
                '\$1000-\$1500',
                'Over \$1500',
              ],
            ),

            const SizedBox(height: 24),

            // Cleanliness slider
            const Text('Cleanliness'),
            _LabeledSlider(
              min: 1,
              max: 5,
              value: cleanlinessLevel,
              onChanged: onCleanlinessChanged,
              labels: const [
                'Very Messy',
                'Messy',
                'Average',
                'Tidy',
                'Very Tidy',
              ],
            ),

            const SizedBox(height: 24),

            // Noise slider
            const Text('Noise Level'),
            _LabeledSlider(
              min: 1,
              max: 5,
              value: noiseLevel,
              onChanged: onNoiseChanged,
              labels: const [
                'Very Quiet',
                'Quiet',
                'Moderate',
                'Lively',
                'Very Loud',
              ],
            ),

            const SizedBox(height: 24),

            // Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Smoking'),
                    Switch(value: smoking, onChanged: onSmokingChanged),
                  ],
                ),
                Row(
                  children: [
                    const Text('Pets'),
                    Switch(value: pets, onChanged: onPetsChanged),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final List<String> labels;

  const _LabeledSlider({
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
