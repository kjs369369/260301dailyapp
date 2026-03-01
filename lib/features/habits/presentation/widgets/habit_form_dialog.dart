import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class HabitFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialEmoji;
  final String? initialColorHex;
  final String? initialFrequency;
  final String? initialCustomDays;
  final Future<void> Function(
    String name,
    String emoji,
    String colorHex,
    String frequency,
    String? customDays,
  ) onSave;

  const HabitFormDialog({
    super.key,
    this.initialName,
    this.initialEmoji,
    this.initialColorHex,
    this.initialFrequency,
    this.initialCustomDays,
    required this.onSave,
  });

  bool get isEditing => initialName != null;

  @override
  State<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<HabitFormDialog> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  late String _selectedColorHex;
  late String _selectedFrequency;
  late Set<int> _selectedDays; // 1=Mon, 7=Sun
  bool _saving = false;

  static const List<String> _emojiOptions = [
    '✅', '💧', '📚', '🏃', '🧘', '💪', '🍎', '😴',
    '📝', '🎯', '💊', '🧹', '🎵', '🌱', '☀️', '🙏',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedEmoji = widget.initialEmoji ?? '✅';
    _selectedColorHex = widget.initialColorHex ?? '#4CAF50';
    _selectedFrequency = widget.initialFrequency ?? 'daily';
    _selectedDays = _parseCustomDays(widget.initialCustomDays);
  }

  Set<int> _parseCustomDays(String? json) {
    if (json == null) return {1, 2, 3, 4, 5};
    final cleaned = json.replaceAll(RegExp(r'[\[\]\s]'), '');
    return cleaned.split(',').where((s) => s.isNotEmpty).map(int.parse).toSet();
  }

  String _customDaysToJson() => '[${_selectedDays.toList()..sort()}]'
      .replaceAll('(', '')
      .replaceAll(')', '');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Text(
              widget.isEditing ? AppStrings.editHabit : AppStrings.addHabit,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Gap(20),

            // Name field
            TextField(
              controller: _nameController,
              autofocus: !widget.isEditing,
              decoration: const InputDecoration(
                labelText: AppStrings.habitName,
                hintText: AppStrings.habitNameHint,
              ),
            ),
            const Gap(20),

            // Emoji selector
            Text(AppStrings.selectEmoji,
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),

            // Color selector
            Text(AppStrings.selectColor,
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppColors.habitPalette.map((color) {
                final hex =
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                final isSelected = hex == _selectedColorHex.toUpperCase();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorHex = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),

            // Frequency selector
            Text(AppStrings.frequency,
                style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text(AppStrings.daily)),
                ButtonSegment(
                    value: 'weekdays', label: Text(AppStrings.weekdaysOnly)),
                ButtonSegment(value: 'custom', label: Text(AppStrings.custom)),
              ],
              selected: {_selectedFrequency},
              onSelectionChanged: (v) =>
                  setState(() => _selectedFrequency = v.first),
            ),

            if (_selectedFrequency == 'custom') ...[
              const Gap(12),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(AppStrings.weekdays[i]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
            const Gap(24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _onSave,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.save),
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await widget.onSave(
        name,
        _selectedEmoji,
        _selectedColorHex,
        _selectedFrequency,
        _selectedFrequency == 'custom' ? _customDaysToJson() : null,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
