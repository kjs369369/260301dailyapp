import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/utils/date_utils.dart' as utils;

class DailyCompletionRate {
  final DateTime date;
  final int completed;
  final int total;

  DailyCompletionRate({
    required this.date,
    required this.completed,
    required this.total,
  });

  double get rate => total == 0 ? 0 : completed / total;
}

class HabitStreak {
  final int habitId;
  final String habitName;
  final String emoji;
  final int currentStreak;
  final int longestStreak;

  HabitStreak({
    required this.habitId,
    required this.habitName,
    required this.emoji,
    required this.currentStreak,
    required this.longestStreak,
  });
}

/// Weekly completion rates (Mon-Sun of current week)
final weeklyStatsProvider = FutureProvider<List<DailyCompletionRate>>((ref) async {
  final db = ref.watch(databaseProvider);
  final week = utils.weekDates(utils.today());
  final habits = await db.getAllHabits();
  final total = habits.length;

  final records = await db.getRecordsInRange(week.first, week.last);

  // Group records by date
  final byDate = <DateTime, int>{};
  for (final r in records) {
    if (r.isCompleted) {
      final d = utils.dateOnly(r.date);
      byDate[d] = (byDate[d] ?? 0) + 1;
    }
  }

  return week.map((date) {
    return DailyCompletionRate(
      date: date,
      completed: byDate[date] ?? 0,
      total: total,
    );
  }).toList();
});

/// Monthly completion rates (each day of current month)
final monthlyStatsProvider = FutureProvider<List<DailyCompletionRate>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = utils.today();
  final start = utils.startOfMonth(now);
  final end = now; // Only up to today

  final habits = await db.getAllHabits();
  final total = habits.length;
  final records = await db.getRecordsInRange(start, end);

  final byDate = <DateTime, int>{};
  for (final r in records) {
    if (r.isCompleted) {
      final d = utils.dateOnly(r.date);
      byDate[d] = (byDate[d] ?? 0) + 1;
    }
  }

  final days = <DailyCompletionRate>[];
  var day = start;
  while (!day.isAfter(end)) {
    days.add(DailyCompletionRate(
      date: day,
      completed: byDate[day] ?? 0,
      total: total,
    ));
    day = day.add(const Duration(days: 1));
  }
  return days;
});

/// Streaks for all habits
final streaksProvider = FutureProvider<List<HabitStreak>>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.getAllHabits();
  final now = utils.today();

  final streaks = <HabitStreak>[];

  for (final habit in habits) {
    // Get all records for this habit, sorted by date desc
    final records = await db.getRecordsForHabitInRange(
      habit.id,
      DateTime(2020),
      now,
    );

    final completedDates = <DateTime>{};
    for (final r in records) {
      if (r.isCompleted) {
        completedDates.add(utils.dateOnly(r.date));
      }
    }

    // Calculate current streak
    int currentStreak = 0;
    var checkDay = now;
    while (completedDates.contains(checkDay)) {
      currentStreak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDates = completedDates.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      if (i == 0) {
        tempStreak = 1;
      } else {
        final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) longestStreak = tempStreak;
    }

    streaks.add(HabitStreak(
      habitId: habit.id,
      habitName: habit.name,
      emoji: habit.emoji,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    ));
  }

  return streaks;
});

/// Overall completion rate
final overallCompletionRateProvider = FutureProvider<double>((ref) async {
  final monthly = await ref.watch(monthlyStatsProvider.future);
  if (monthly.isEmpty) return 0;

  int totalCompleted = 0;
  int totalPossible = 0;
  for (final day in monthly) {
    totalCompleted += day.completed;
    totalPossible += day.total;
  }

  return totalPossible == 0 ? 0 : totalCompleted / totalPossible;
});
