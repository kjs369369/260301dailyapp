import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/habits_table.dart';
import 'tables/habit_records_table.dart';
import 'tables/journal_entries_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits, HabitRecords, JournalEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // ─── Habit Queries ───

  Stream<List<Habit>> watchAllHabits() {
    return (select(habits)
          ..where((h) => h.isActive.equals(true))
          ..orderBy([(h) => OrderingTerm.asc(h.sortOrder)]))
        .watch();
  }

  Future<List<Habit>> getAllHabits() {
    return (select(habits)
          ..where((h) => h.isActive.equals(true))
          ..orderBy([(h) => OrderingTerm.asc(h.sortOrder)]))
        .get();
  }

  Future<int> insertHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  Future<bool> updateHabit(HabitsCompanion habit) {
    return update(habits).replace(Habit(
      id: habit.id.value,
      name: habit.name.value,
      emoji: habit.emoji.value,
      description: habit.description.value,
      sortOrder: habit.sortOrder.value,
      frequency: habit.frequency.value,
      customDays: habit.customDays.value,
      isActive: habit.isActive.value,
      colorHex: habit.colorHex.value,
      createdAt: habit.createdAt.value,
    ));
  }

  Future<int> deleteHabitById(int id) {
    return (update(habits)..where((h) => h.id.equals(id)))
        .write(const HabitsCompanion(isActive: Value(false)));
  }

  Future<void> reorderHabits(List<int> orderedIds) async {
    await batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          habits,
          HabitsCompanion(sortOrder: Value(i)),
          where: (h) => h.id.equals(orderedIds[i]),
        );
      }
    });
  }

  // ─── Habit Record Queries ───

  Stream<List<HabitRecord>> watchRecordsForDate(DateTime date) {
    return (select(habitRecords)..where((r) => r.date.equals(date))).watch();
  }

  Future<List<HabitRecord>> getRecordsForDate(DateTime date) {
    return (select(habitRecords)..where((r) => r.date.equals(date))).get();
  }

  Future<List<HabitRecord>> getRecordsForHabitInRange(
    int habitId,
    DateTime start,
    DateTime end,
  ) {
    return (select(habitRecords)
          ..where(
            (r) =>
                r.habitId.equals(habitId) &
                r.date.isBiggerOrEqualValue(start) &
                r.date.isSmallerOrEqualValue(end),
          ))
        .get();
  }

  Future<List<HabitRecord>> getRecordsInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(habitRecords)
          ..where(
            (r) =>
                r.date.isBiggerOrEqualValue(start) &
                r.date.isSmallerOrEqualValue(end),
          ))
        .get();
  }

  Stream<List<HabitRecord>> watchRecordsInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(habitRecords)
          ..where(
            (r) =>
                r.date.isBiggerOrEqualValue(start) &
                r.date.isSmallerOrEqualValue(end),
          ))
        .watch();
  }

  Future<void> toggleHabitRecord(int habitId, DateTime date) async {
    final existing = await (select(habitRecords)
          ..where(
            (r) => r.habitId.equals(habitId) & r.date.equals(date),
          ))
        .getSingleOrNull();

    if (existing == null) {
      await into(habitRecords).insert(HabitRecordsCompanion.insert(
        habitId: habitId,
        date: date,
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ));
    } else {
      final newCompleted = !existing.isCompleted;
      await (update(habitRecords)..where((r) => r.id.equals(existing.id)))
          .write(HabitRecordsCompanion(
        isCompleted: Value(newCompleted),
        completedAt: Value(newCompleted ? DateTime.now() : null),
      ));
    }
  }

  // ─── Journal Queries ───

  Stream<JournalEntry?> watchJournalForDate(DateTime date) {
    return (select(journalEntries)..where((j) => j.date.equals(date)))
        .watchSingleOrNull();
  }

  Future<JournalEntry?> getJournalForDate(DateTime date) {
    return (select(journalEntries)..where((j) => j.date.equals(date)))
        .getSingleOrNull();
  }

  Stream<List<JournalEntry>> watchAllJournals() {
    return (select(journalEntries)
          ..orderBy([(j) => OrderingTerm.desc(j.date)]))
        .watch();
  }

  Future<void> upsertJournal({
    required DateTime date,
    required String content,
    String? title,
    int? mood,
  }) async {
    final existing = await getJournalForDate(date);
    if (existing == null) {
      await into(journalEntries).insert(JournalEntriesCompanion.insert(
        date: date,
        content: content,
        title: Value(title),
        mood: Value(mood),
      ));
    } else {
      await (update(journalEntries)..where((j) => j.id.equals(existing.id)))
          .write(JournalEntriesCompanion(
        content: Value(content),
        title: Value(title),
        mood: Value(mood),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  Future<int> deleteJournal(int id) {
    return (delete(journalEntries)..where((j) => j.id.equals(id))).go();
  }

  Future<List<JournalEntry>> getJournalsInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(journalEntries)
          ..where(
            (j) =>
                j.date.isBiggerOrEqualValue(start) &
                j.date.isSmallerOrEqualValue(end),
          ))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'daily_app.sqlite'));
    return SqfliteQueryExecutor.inDatabaseFolder(path: file.path);
  });
}
