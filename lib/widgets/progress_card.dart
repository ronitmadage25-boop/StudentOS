import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable progress card showing a label, percentage, and linear progress.
///
/// Ideal for visualizing syllabus progress, attendance, etc.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.label,
    required this.percentage,
    this.subtitle,
    this.icon,
    this.progressColor = AppColors.primaryBlue,
    this.backgroundColor,
    this.onTap,
  });

  /// Title label (e.g., "Syllabus Progress").
  final String label;

  /// Progress percentage (0 – 100).
  final double percentage;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Color of the progress bar fill.
  final Color progressColor;

  /// Background color of the progress track.
  final Color? backgroundColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trackColor = backgroundColor ?? progressColor.withValues(alpha: 0.12);

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
            // Header row
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      color: progressColor,
                      size: AppDimens.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                ],
                Expanded(
                  child: Text(label, style: AppTextStyles.labelLarge),
                ),
                Text(
                  '${percentage.round()}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: progressColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.md),

            // Progress bar
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusFull),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: AppDimens.progressBarHeight,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: AppDimens.sm),
              Text(subtitle!, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
