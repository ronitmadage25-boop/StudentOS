import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable info card for displaying upcoming events or tasks.
///
/// Supports an icon, title, subtitle, and a trailing badge or chip.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor = AppColors.primaryBlue,
    this.trailing,
    this.onTap,
  });

  /// Primary title text.
  final String title;

  /// Subtitle or description text.
  final String subtitle;

  /// Leading icon.
  final IconData? icon;

  /// Color for the icon background.
  final Color iconColor;

  /// Optional trailing widget (e.g., a badge or chip).
  final Widget? trailing;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
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
            // Icon container
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: AppDimens.iconLg),
              ),
              const SizedBox(width: AppDimens.lg),
            ],

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppDimens.xs),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            trailingWidget ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
