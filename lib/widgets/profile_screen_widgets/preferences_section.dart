import 'package:flutter/material.dart';

class PreferencesSection extends StatelessWidget {
  final double cleanlinessLevel;
  final double noiseLevel;
  final double budgetLevel;
  final bool smoking;
  final bool pets;

  const PreferencesSection({
    super.key,
    required this.cleanlinessLevel,
    required this.noiseLevel,
    required this.budgetLevel,
    required this.smoking,
    required this.pets,
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

            _buildPreferenceDisplay(
              context,
              title: 'Budget',
              value: budgetLevel,
              labels: const [
                'Under €100',
                '€100-€300',
                '€300-€500',
                '€500-€1000',
                'Over €1000',
              ],
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            _buildPreferenceDisplay(
              context,
              title: 'Cleanliness',
              value: cleanlinessLevel,
              labels: const [
                'Very Messy',
                'Messy',
                'Average',
                'Tidy',
                'Very Tidy',
              ],
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            _buildPreferenceDisplay(
              context,
              title: 'Noise Level',
              value: noiseLevel,
              labels: const [
                'Very Quiet',
                'Quiet',
                'Moderate',
                'Lively',
                'Very Loud',
              ],
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            // Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBooleanDisplay(context, 'Smoking', smoking),
                _buildBooleanDisplay(context, 'Pets', pets),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceDisplay(
    BuildContext context, {
    required String title,
    required double value,
    required List<String> labels,
    required Color color,
  }) {
    // Ensure index is within range [0, 4]
    final int index = (value.round() - 1).clamp(0, labels.length - 1);
    final String label = labels[index];
    // value 1..5 -> normalized 0.2..1.0
    final double normalizedValue = value / 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              label,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(1.0),
                  fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: normalizedValue,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBooleanDisplay(BuildContext context, String title, bool value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              value ? Icons.check_circle_outline : Icons.highlight_off,
              color: value ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              value ? "Allowed" : "No",
              style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(1.0)),
            ),
          ],
        ),
      ],
    );
  }
}
