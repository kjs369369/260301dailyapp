import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/providers/home_providers.dart';
import 'widgets/habit_form_dialog.dart';

class HabitManagementScreen extends ConsumerWidget {
  const HabitManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(allHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageHabits),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_task,
                    size: 64,
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
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final ids = habits.map((h) => h.id).toList();
              final id = ids.removeAt(oldIndex);
              ids.insert(newIndex, id);
              ref.read(databaseProvider).reorderHabits(ids);
            },
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _HabitCard(
                key: ValueKey(habit.id),
                habit: habit,
                onEdit: () => _showEditDialog(context, ref, habit),
                onDelete: () => _confirmDelete(context, ref, habit.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HabitFormDialog(
        onSave: (name, emoji, colorHex, frequency, customDays) async {
          final db = ref.read(databaseProvider);
          final habits = await db.getAllHabits();
          await db.insertHabit(HabitsCompanion.insert(
            name: name,
            emoji: Value(emoji),
            colorHex: Value(colorHex),
            frequency: Value(frequency),
            customDays: Value(customDays),
            sortOrder: Value(habits.length),
          ));
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HabitFormDialog(
        initialName: habit.name,
        initialEmoji: habit.emoji,
        initialColorHex: habit.colorHex,
        initialFrequency: habit.frequency,
        initialCustomDays: habit.customDays,
        onSave: (name, emoji, colorHex, frequency, customDays) async {
          final db = ref.read(databaseProvider);
          await db.updateHabit(HabitsCompanion(
            id: Value(habit.id),
            name: Value(name),
            emoji: Value(emoji),
            colorHex: Value(colorHex),
            frequency: Value(frequency),
            customDays: Value(customDays),
            sortOrder: Value(habit.sortOrder),
            isActive: Value(habit.isActive),
            createdAt: Value(habit.createdAt),
          ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int habitId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteHabit),
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(databaseProvider).deleteHabitById(habitId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitCard({
    super.key,
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(habit.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(habit.name),
        subtitle: Text(
          _frequencyLabel(habit.frequency),
          style: TextStyle(color: color),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              iconSize: 20,
              color: AppColors.error,
            ),
            const Icon(Icons.drag_handle, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return AppStrings.daily;
      case 'weekdays':
        return AppStrings.weekdaysOnly;
      case 'custom':
        return AppStrings.custom;
      default:
        return frequency;
    }
  }

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
