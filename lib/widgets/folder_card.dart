import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable card for file/folder navigation (PYQ library).
class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.folder_rounded,
    this.iconColor = AppColors.primaryBlue,
    this.itemCount,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final int? itemCount;
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppDimens.iconLg,
              ),
            ),
            const SizedBox(width: AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (itemCount != null) ...[
              Text(
                '$itemCount items',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppDimens.sm),
            ],
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
