import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';

class TodaySummaryCard extends StatelessWidget {
  final int completed;
  final int total;

  const TodaySummaryCard({
    super.key,
    required this.completed,
    required this.total,
  });

  double get _progress => total == 0 ? 0 : completed / total;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                      _progress >= 1.0
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(_progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed / $total 완료',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Gap(4),
                  Text(
                    _progress >= 1.0
                        ? '오늘 습관을 모두 완료했어요! 🎉'
                        : '조금만 더 힘내세요!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
