import 'package:flutter/material.dart';
import '../../widgets/common/labeled_slider.dart';

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
            LabeledSlider(
              min: 1,
              max: 19,
              value: budgetLevel,
              onChanged: onBudgetChanged,
              labels: const [
                '€0-150',
                '€150-200',
                '€200-250',
                '€250-300',
                '€300-350',
                '€350-400',
                '€400-450',
                '€450-500',
                '€500-550',
                '€550-600',
                '€600-650',
                '€650-700',
                '€700-750',
                '€750-800',
                '€800-850',
                '€850-900',
                '€900-950',
                '€950-1000',
                'Over €1000',
              ],
            ),

            const SizedBox(height: 24),

            // Cleanliness slider
            const Text('Cleanliness'),
            LabeledSlider(
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
            LabeledSlider(
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
