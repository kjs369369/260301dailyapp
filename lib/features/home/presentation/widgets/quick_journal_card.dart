import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as utils;
import '../../providers/home_providers.dart';

class QuickJournalCard extends ConsumerWidget {
  const QuickJournalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(todayJournalProvider);
    final todayStr = utils.today().toIso8601String().split('T').first;

    return journalAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (journal) {
        final hasEntry = journal != null;

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => context.go('/home/journal/$todayStr'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    hasEntry ? Icons.edit_note : Icons.create_outlined,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasEntry
                              ? AppStrings.editJournal
                              : AppStrings.writeJournal,
                          style:
                              Theme.of(context).textTheme.titleMedium,
                        ),
                        if (hasEntry) ...[
                          const Gap(4),
                          Text(
                            journal.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else ...[
                          const Gap(4),
                          Text(
                            AppStrings.noJournalYet,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textDisabled,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textDisabled,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
