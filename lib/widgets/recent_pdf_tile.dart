import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';
import '../models/models.dart';

/// A list tile displaying a single recently opened PDF file.
///
/// Shows:
///   • PDF icon with accent
///   • File name
///   • Subject name (in gray)
///
/// Used in the Recently Opened section at the top of Library screen.
class RecentPdfTile extends StatelessWidget {
  const RecentPdfTile({
    super.key,
    required this.file,
    this.onTap,
  });

  final LibraryFileModel file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: AppDimens.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // PDF icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.info,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimens.md),

            // File name + subject
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file.subjectName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Forward icon
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: AppDimens.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}
