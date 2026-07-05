import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable card for displaying subject attendance info.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.totalLectures,
    required this.attendedLectures,
    this.onTap,
  });

  final String subjectName;
  final int totalLectures;
  final int attendedLectures;
  final VoidCallback? onTap;

  double get attendancePercentage {
    if (totalLectures == 0) return 0.0;
    return (attendedLectures / totalLectures) * 100;
  }

  Color get statusColor {
    final pct = attendancePercentage;
    if (pct >= 75.0) return AppColors.success;
    if (pct >= 60.0) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final pct = attendancePercentage;
    final color = statusColor;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subjectName,
                    style: AppTextStyles.heading4,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: AppTextStyles.heading4.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              'Attended: $attendedLectures / $totalLectures lectures',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppDimens.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: LinearProgressIndicator(
                value: totalLectures == 0 ? 0.0 : (attendedLectures / totalLectures),
                minHeight: AppDimens.progressBarHeight,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
