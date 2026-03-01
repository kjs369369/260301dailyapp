import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class CompletionRateCard extends StatelessWidget {
  final double rate;

  const CompletionRateCard({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).round();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                      rate >= 0.8
                          ? AppColors.success
                          : rate >= 0.5
                              ? AppColors.primary
                              : AppColors.warning,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.thisMonth} ${AppStrings.completionRate}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(4),
                  Text(
                    rate >= 0.8
                        ? '훌륭해요! 꾸준히 하고 있어요'
                        : rate >= 0.5
                            ? '좋아요! 조금 더 힘내봐요'
                            : '천천히 시작해봐요',
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
