import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable card for displaying exam countdown info.
class ExamCard extends StatelessWidget {
  const ExamCard({
    super.key,
    required this.examName,
    required this.subjectName,
    required this.daysLeft,
    required this.examType,
    this.onTap,
  });

  final String examName;
  final String subjectName;
  final int daysLeft;
  final String examType;
  final VoidCallback? onTap;

  Color get countdownColor {
    if (daysLeft <= 7) return AppColors.error;
    if (daysLeft <= 14) return AppColors.warning;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final color = countdownColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: color,
                size: AppDimens.iconLg,
              ),
            ),
            const SizedBox(width: AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examName,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    subjectName,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.md,
                    vertical: AppDimens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    '$daysLeft days left',
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                ),
                const SizedBox(height: AppDimens.xs),
                Text(
                  examType,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
