import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as utils;
import '../../../home/providers/home_providers.dart';

class DayDetailSheet extends ConsumerWidget {
  final DateTime date;

  const DayDetailSheet({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);
    final dateStr = date.toIso8601String().split('T').first;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),
          Text(
            utils.formatFullDate(date),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Gap(16),

          // Habits for this day
          habitsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
            data: (habits) {
              if (habits.isEmpty) {
                return const Text('등록된 습관이 없습니다');
              }

              return FutureBuilder(
                future: ref
                    .read(databaseProvider)
                    .getRecordsForDate(utils.dateOnly(date)),
                builder: (context, snapshot) {
                  final records = snapshot.data ?? [];
                  final recordMap = {
                    for (final r in records) r.habitId: r,
                  };

                  return Column(
                    children: habits.map((habit) {
                      final record = recordMap[habit.id];
                      final isCompleted = record?.isCompleted ?? false;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text(habit.emoji,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.textDisabled,
                        ),
                        onTap: () {
                          ref
                              .read(databaseProvider)
                              .toggleHabitRecord(habit.id, utils.dateOnly(date));
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),

          const Gap(12),
          const Divider(),
          const Gap(8),

          // Journal link
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_note, color: AppColors.secondary),
            title: const Text(AppStrings.journalTitle),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textDisabled),
            onTap: () {
              Navigator.pop(context);
              context.go('/calendar/journal/$dateStr');
            },
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
