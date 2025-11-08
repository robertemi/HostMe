import 'package:flutter/material.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({
    super.key,
    required this.lookingForIndex,
    required this.onLookingForChanged,
    required this.budgetMin,
    required this.budgetMax,
    required this.budgetValue,
    required this.onBudgetChanged,
    required this.cleanlinessLabel,
    required this.cleanlinessPercent,
    required this.noiseLabel,
    required this.noisePercent,
    required this.smoking,
    required this.onSmokingChanged,
    required this.pets,
    required this.onPetsChanged,
  });

  final int lookingForIndex; // 0 roommate,1 place,2 both
  final ValueChanged<int> onLookingForChanged;
  final double budgetMin;
  final double budgetMax;
  final double budgetValue;
  final ValueChanged<double> onBudgetChanged;
  final String cleanlinessLabel;
  final double cleanlinessPercent;
  final String noiseLabel;
  final double noisePercent;
  final bool smoking;
  final ValueChanged<bool> onSmokingChanged;
  final bool pets;
  final ValueChanged<bool> onPetsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _LabeledBlock(
          label: 'Looking For',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onLookingForChanged(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: lookingForIndex == i
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          const ['Roommate', 'Place', 'Both'][i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: lookingForIndex == i
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: lookingForIndex == i
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _LabeledBlock(
          label: 'Budget Range',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('4${budgetMin.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('4${budgetMax.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Slider(
                min: budgetMin,
                max: budgetMax,
                value: budgetValue.clamp(budgetMin, budgetMax),
                label: '4${budgetValue.round()}',
                onChanged: onBudgetChanged,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Colors.white24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _AttributeBar(
          label: 'Cleanliness',
          valueLabel: cleanlinessLabel,
          percent: cleanlinessPercent,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        _AttributeBar(
          label: 'Noise Level',
          valueLabel: noiseLabel,
          percent: noisePercent,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Smoking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            _Switch(smoking, onSmokingChanged),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            _Switch(pets, onPetsChanged),
          ],
        ),
      ],
    );
  }
}

class _LabeledBlock extends StatelessWidget {
  const _LabeledBlock({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AttributeBar extends StatelessWidget {
  const _AttributeBar({
    required this.label,
    required this.valueLabel,
    required this.percent,
    required this.color,
  });
  final String label;
  final String valueLabel;
  final double percent;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(valueLabel, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 8,
            color: Colors.white.withOpacity(0.25),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent.clamp(0, 1),
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch(this.value, this.onChanged);
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 28,
        width: 52,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: value ? Theme.of(context).primaryColor : Colors.white24,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
