import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable list tile for profile/settings screens.
class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingColor = AppColors.primaryBlue,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Color leadingColor;
  final Widget? trailing;
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
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: leadingColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(
                  leading,
                  color: leadingColor,
                  size: AppDimens.iconMd,
                ),
              ),
              const SizedBox(width: AppDimens.lg),
            ],
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
            trailing ??
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
