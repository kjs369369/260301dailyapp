import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../providers/calendar_providers.dart';
import 'widgets/day_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = utils.today();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(monthSummaryProvider(_focusedDay));

    return Scaffold(
      appBar: AppBar(
        title: Text(utils.formatYearMonth(_focusedDay)),
      ),
      body: Column(
        children: [
          summaryAsync.when(
            loading: () => const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Center(child: Text('오류: $e')),
            data: (summaries) {
              return TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) =>
                    _selectedDay != null &&
                    utils.isSameDay(day, _selectedDay!),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showDayDetail(selectedDay);
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle:
                      const TextStyle(color: AppColors.textPrimary),
                  weekendTextStyle:
                      const TextStyle(color: AppColors.textSecondary),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle:
                      const TextStyle(color: AppColors.textPrimary),
                ),
                headerVisible: false,
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textSecondary),
                  weekendStyle: TextStyle(color: AppColors.textDisabled),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final key = utils.dateOnly(date);
                    final summary = summaries[key];
                    if (summary == null) return null;

                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (summary.completedHabits > 0)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: summary.completionRate >= 1.0
                                    ? AppColors.success
                                    : AppColors.primary
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                          if (summary.hasJournalEntry) ...[
                            const SizedBox(width: 3),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const Gap(8),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _legendDot(AppColors.success, '습관 완료'),
                const Gap(16),
                _legendDot(AppColors.primary.withValues(alpha: 0.6), '일부 완료'),
                const Gap(16),
                _legendDot(AppColors.secondary, '일기 작성'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const Gap(4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showDayDetail(DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (_) => DayDetailSheet(date: date),
    );
  }
}
