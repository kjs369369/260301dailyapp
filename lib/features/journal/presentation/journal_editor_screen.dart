import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart' as utils;
import 'widgets/mood_selector.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const JournalEditorScreen({super.key, required this.date});

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int? _mood;
  Timer? _saveTimer;
  bool _loaded = false;
  bool _saved = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(databaseProvider);
    final entry = await db.getJournalForDate(widget.date);
    if (entry != null && mounted) {
      setState(() {
        _titleController.text = entry.title ?? '';
        _contentController.text = entry.content;
        _mood = entry.mood;
        _loaded = true;
      });
    } else {
      setState(() => _loaded = true);
    }
  }

  void _onChanged() {
    setState(() => _saved = false);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final db = ref.read(databaseProvider);
    await db.upsertJournal(
      date: widget.date,
      content: content,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      mood: _mood,
    );
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Final save on dispose
    if (!_saved) {
      final content = _contentController.text.trim();
      if (content.isNotEmpty) {
        ref.read(databaseProvider).upsertJournal(
          date: widget.date,
          content: content,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          mood: _mood,
        );
      }
    }
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(utils.formatShortDate(widget.date)),
        actions: [
          if (_saved && _contentController.text.trim().isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.cloud_done_outlined,
                      size: 16, color: AppColors.success),
                  Gap(4),
                  Text(
                    AppStrings.autoSaved,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Mood selector
                Text(AppStrings.mood,
                    style: Theme.of(context).textTheme.titleMedium),
                const Gap(10),
                MoodSelector(
                  selectedMood: _mood,
                  onChanged: (mood) {
                    setState(() => _mood = mood);
                    _onChanged();
                  },
                ),
                const Gap(20),

                // Title
                TextField(
                  controller: _titleController,
                  onChanged: (_) => _onChanged(),
                  decoration: const InputDecoration(
                    hintText: AppStrings.titleHint,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(16),

                // Content
                TextField(
                  controller: _contentController,
                  onChanged: (_) => _onChanged(),
                  maxLines: null,
                  minLines: 10,
                  decoration: const InputDecoration(
                    hintText: AppStrings.journalHint,
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
    );
  }
}
