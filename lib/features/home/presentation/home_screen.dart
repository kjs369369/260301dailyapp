import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../providers/home_providers.dart';
import 'widgets/habit_tile.dart';
import 'widgets/quick_journal_card.dart';
import 'widgets/today_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);
    final recordsAsync = ref.watch(todayRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(utils.formatFullDate(utils.today())),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: AppStrings.manageHabits,
            onPressed: () => context.go('/home/manage-habits'),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return _buildEmptyState(context);
          }

          return recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (records) {
              final recordMap = {
                for (final r in records) r.habitId: r,
              };
              final completed =
                  records.where((r) => r.isCompleted).length;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Gap(8),
                  TodaySummaryCard(
                    completed: completed,
                    total: habits.length,
                  ),
                  const Gap(16),
                  Text(
                    AppStrings.todayHabits,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(8),
                  ...habits.map((habit) {
                    final record = recordMap[habit.id];
                    final isCompleted = record?.isCompleted ?? false;
                    return HabitTile(
                      habit: habit,
                      isCompleted: isCompleted,
                      onToggle: () => toggleHabit(ref, habit.id),
                    );
                  }),
                  const Gap(16),
                  const QuickJournalCard(),
                  const Gap(24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const Gap(16),
          Text(
            AppStrings.noHabitsYet,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(24),
          FilledButton.icon(
            onPressed: () => context.go('/home/manage-habits'),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addHabit),
          ),
        ],
      ),
    );
  }
}
