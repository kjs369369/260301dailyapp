import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class MoodSelector extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
  });

  static const _moodColors = [
    AppColors.moodTerrible,
    AppColors.moodBad,
    AppColors.moodNeutral,
    AppColors.moodGood,
    AppColors.moodGreat,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final moodValue = index + 1;
        final isSelected = selectedMood == moodValue;

        return GestureDetector(
          onTap: () => onChanged(moodValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? _moodColors[index].withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: _moodColors[index], width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.moodEmojis[index],
                  style: TextStyle(fontSize: isSelected ? 32 : 26),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.moodLabels[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? _moodColors[index]
                        : AppColors.textDisabled,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
