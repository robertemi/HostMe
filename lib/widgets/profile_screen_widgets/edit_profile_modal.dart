import 'package:flutter/material.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({
    super.key,
    required this.initialName,
    required this.initialBio,
    required this.initialBudgetLevel,
    required this.initialCleanliness,
    required this.initialNoise,
    required this.initialSmoking,
    required this.initialPets,
    required this.initialOccupation,
    required this.onSave,
  });

  final String initialName;
  final String initialBio;
  final double initialBudgetLevel; // 1..5
  final double initialCleanliness; // 1..5
  final double initialNoise; // 1..5
  final bool initialSmoking;
  final String? initialOccupation;
  final bool initialPets;
  final void Function({
    required String name,
    required String bio,
    required String? occupation,
    required double budgetLevel,
    required double cleanlinessLevel,
    required double noiseLevel,
    required bool smoking,
    required bool pets,
  }) onSave;

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late double _budgetLevel;
  late double _cleanliness;
  late double _noise;
  late bool _smoking;
  late bool _pets;
  late String? _occupation; // display case (e.g. Student)

  final List<String> _occupations = const [
    'Student',
    'Employee',
    'Unemployed',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl = TextEditingController(text: widget.initialBio);
    _budgetLevel = widget.initialBudgetLevel;
    _cleanliness = widget.initialCleanliness;
    _noise = widget.initialNoise;
    _smoking = widget.initialSmoking;
    _pets = widget.initialPets;
    if (widget.initialOccupation != null && widget.initialOccupation!.isNotEmpty) {
      // stored lowercase in model; convert to display form by capitalizing first letter
      final raw = widget.initialOccupation!;
      _occupation = raw[0].toUpperCase() + raw.substring(1);
    } else {
      _occupation = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

    Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required List<String> labels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Slider(
          value: value,
          min: 1,
          max: labels.length.toDouble(),
          divisions: labels.length - 1,
          label: labels[value.toInt() - 1],
          onChanged: onChanged,
        ),
        Text(labels[value.toInt() - 1], style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Occupation chips
            Text('Occupation', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _occupations.map((o) {
                final selected = _occupation == o;
                return FilterChip(
                  label: Text(o),
                  selected: selected,
                  onSelected: (_) => setState(() => _occupation = o),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Budget',
              value: _budgetLevel,
              onChanged: (v) => setState(() => _budgetLevel = v),
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
            _buildSlider(
              label: 'Cleanliness',
              value: _cleanliness,
              onChanged: (v) => setState(() => _cleanliness = v),
              labels: const ['Low', 'Moderate', 'Average', 'High', 'Very High'],
            ),
            _buildSlider(
              label: 'Noise',
              value: _noise,
              onChanged: (v) => setState(() => _noise = v),
              labels: const ['Very Quiet', 'Quiet', 'Average', 'Lively', 'Very Lively'],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Smoking'),
                    value: _smoking,
                    onChanged: (v) => setState(() => _smoking = v),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pets'),
                    value: _pets,
                    onChanged: (v) => setState(() => _pets = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      name: _nameCtrl.text.trim(),
                      bio: _bioCtrl.text.trim(),
                      occupation: _occupation?.toLowerCase(),
                      budgetLevel: _budgetLevel,
                      cleanlinessLevel: _cleanliness,
                      noiseLevel: _noise,
                      smoking: _smoking,
                      pets: _pets,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
