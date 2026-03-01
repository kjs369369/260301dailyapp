import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/statistics_providers.dart';

class StreakDisplay extends StatelessWidget {
  final List<HabitStreak> streaks;

  const StreakDisplay({super.key, required this.streaks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: streaks.map((streak) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(streak.emoji, style: const TextStyle(fontSize: 28)),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak.habitName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          _streakBadge(
                            context,
                            AppStrings.currentStreak,
                            streak.currentStreak,
                            AppColors.secondary,
                          ),
                          const Gap(12),
                          _streakBadge(
                            context,
                            AppStrings.longestStreak,
                            streak.longestStreak,
                            AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (streak.currentStreak > 0)
                  Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: streak.currentStreak >= 7 ? 28 : 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _streakBadge(
    BuildContext context,
    String label,
    int days,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textDisabled),
        ),
        const Gap(4),
        Text(
          '$days${AppStrings.days}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
