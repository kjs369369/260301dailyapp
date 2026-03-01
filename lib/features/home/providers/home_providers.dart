import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/date_utils.dart' as utils;

/// Watches all active habits
final allHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllHabits();
});

/// Watches today's habit records
final todayRecordsProvider = StreamProvider<List<HabitRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecordsForDate(utils.today());
});

/// Today's journal entry
final todayJournalProvider = StreamProvider<JournalEntry?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchJournalForDate(utils.today());
});

/// Toggle a habit's completion for today
Future<void> toggleHabit(WidgetRef ref, int habitId) async {
  final db = ref.read(databaseProvider);
  await db.toggleHabitRecord(habitId, utils.today());
}
