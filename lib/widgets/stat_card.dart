import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable statistic card for the dashboard.
///
/// Displays a label, a large stat value, optional subtitle, and a colored
/// accent bar on the left side.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor = AppColors.primaryBlue,
    this.onTap,
  });

  /// Title of the stat (e.g., "Attendance").
  final String label;

  /// Primary value to display prominently (e.g., "82%").
  final String value;

  /// Optional subtitle below the value (e.g., "Last 30 days").
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Accent color for the left bar indicator.
  final Color accentColor;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
            // Accent bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
            ),
            const SizedBox(width: AppDimens.md),

            // Icon
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(icon, color: accentColor, size: AppDimens.iconMd),
              ),
              const SizedBox(width: AppDimens.md),
            ],

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    value,
                    style: AppTextStyles.heading3.copyWith(color: accentColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),

            // Chevron
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: AppDimens.iconLg,
              ),
          ],
        ),
      ),
    );
  }
}
