import 'package:intl/intl.dart';

/// Date utility functions for consistent date handling.
/// All dates stored in DB should use [dateOnly] to strip time components.
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Format: "2026년 3월 1일 일요일"
String formatFullDate(DateTime date) {
  return DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(date);
}

/// Format: "3월 1일"
String formatShortDate(DateTime date) {
  return DateFormat('M월 d일', 'ko_KR').format(date);
}

/// Format: "2026년 3월"
String formatYearMonth(DateTime date) {
  return DateFormat('yyyy년 M월', 'ko_KR').format(date);
}

/// Returns the weekday index (1=Monday, 7=Sunday) matching Dart's DateTime.weekday
int weekdayIndex(DateTime date) => date.weekday;

/// Returns the start of the week (Monday) for the given date
DateTime startOfWeek(DateTime date) {
  final d = dateOnly(date);
  return d.subtract(Duration(days: d.weekday - 1));
}

/// Returns a list of 7 dates for the week containing [date]
List<DateTime> weekDates(DateTime date) {
  final start = startOfWeek(date);
  return List.generate(7, (i) => start.add(Duration(days: i)));
}

/// Returns the first day of the month
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

/// Returns the last day of the month
DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);
