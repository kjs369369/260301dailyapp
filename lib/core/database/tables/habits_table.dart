import 'package:drift/drift.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get emoji =>
      text().withLength(min: 1, max: 10).withDefault(const Constant('✅'))();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 'daily', 'weekdays', 'custom'
  TextColumn get frequency =>
      text().withDefault(const Constant('daily'))();

  /// JSON array of weekday indices for custom frequency, e.g. "[1,2,3,4,5]"
  TextColumn get customDays => text().nullable()();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  /// Hex color string, e.g. "#4CAF50"
  TextColumn get colorHex =>
      text().withDefault(const Constant('#4CAF50'))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
