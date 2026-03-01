import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/statistics_providers.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/monthly_chart.dart';
import 'widgets/streak_display.dart';
import 'widgets/completion_rate_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final monthlyAsync = ref.watch(monthlyStatsProvider);
    final streaksAsync = ref.watch(streaksProvider);
    final overallAsync = ref.watch(overallCompletionRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navStatistics),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall completion rate
          overallAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (rate) => CompletionRateCard(rate: rate),
          ),
          const Gap(16),

          // Weekly chart
          Text(AppStrings.thisWeek,
              style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          weeklyAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('오류: $e'),
            data: (data) {
              if (data.every((d) => d.total == 0)) {
                return _emptyCard(context);
              }
              return WeeklyChart(data: data);
            },
          ),
          const Gap(20),

          // Monthly chart
          Text(AppStrings.thisMonth,
              style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          monthlyAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('오류: $e'),
            data: (data) {
              if (data.every((d) => d.total == 0)) {
                return _emptyCard(context);
              }
              return MonthlyChart(data: data);
            },
          ),
          const Gap(20),

          // Streaks
          Text('연속 달성',
              style: Theme.of(context).textTheme.titleLarge),
          const Gap(8),
          streaksAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
            data: (streaks) {
              if (streaks.isEmpty) return _emptyCard(context);
              return StreakDisplay(streaks: streaks);
            },
          ),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            AppStrings.noDataYet,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }
}
