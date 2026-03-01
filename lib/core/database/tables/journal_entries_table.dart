import 'package:drift/drift.dart';

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  TextColumn get content => text()();

  /// Mood rating: 1 (very bad) to 5 (very good)
  IntColumn get mood => integer().nullable()();

  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
