import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/utils/date_utils.dart' as utils;

class DaySummary {
  final DateTime date;
  final int totalHabits;
  final int completedHabits;
  final bool hasJournalEntry;

  DaySummary({
    required this.date,
    required this.totalHabits,
    required this.completedHabits,
    required this.hasJournalEntry,
  });

  double get completionRate =>
      totalHabits == 0 ? 0 : completedHabits / totalHabits;
}

/// Provides a map of date -> DaySummary for the given month
final monthSummaryProvider =
    FutureProvider.family<Map<DateTime, DaySummary>, DateTime>(
  (ref, focusedDay) async {
    final db = ref.watch(databaseProvider);
    final start = utils.startOfMonth(focusedDay);
    final end = utils.endOfMonth(focusedDay);

    final habits = await db.getAllHabits();
    final records = await db.getRecordsInRange(start, end);
    final journals = await db.getJournalsInRange(start, end);

    final journalDates = <DateTime>{};
    for (final j in journals) {
      journalDates.add(utils.dateOnly(j.date));
    }

    final Map<DateTime, DaySummary> result = {};

    // Group records by date
    final recordsByDate = <DateTime, List<dynamic>>{};
    for (final r in records) {
      final d = utils.dateOnly(r.date);
      recordsByDate.putIfAbsent(d, () => []).add(r);
    }

    // Build summary for each day in the month
    var day = start;
    while (!day.isAfter(end)) {
      final dayRecords = recordsByDate[day] ?? [];
      final completed =
          dayRecords.where((r) => r.isCompleted as bool).length;

      if (completed > 0 || journalDates.contains(day)) {
        result[day] = DaySummary(
          date: day,
          totalHabits: habits.length,
          completedHabits: completed,
          hasJournalEntry: journalDates.contains(day),
        );
      }

      day = day.add(const Duration(days: 1));
    }

    return result;
  },
);
