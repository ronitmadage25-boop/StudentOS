import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_dimens.dart';

/// A placeholder screen for features that are not yet implemented.
///
/// Displays the screen title, a relevant icon, and a "Coming Soon" message.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
  });

  /// Screen title shown in the AppBar and center.
  final String title;

  /// Icon shown in the center of the placeholder.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                ),
                child: Icon(
                  icon,
                  size: AppDimens.iconHuge,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppDimens.xxl),
              Text(
                title,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                AppStrings.featureComingSoon,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
