import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(habit.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCompleted
          ? color.withValues(alpha: 0.15)
          : AppColors.surface,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                habit.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              _buildCheckbox(color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? color : AppColors.textDisabled,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
