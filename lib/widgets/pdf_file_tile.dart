import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';
import '../models/models.dart';

/// A list tile displaying a single imported PDF file.
///
/// Shows:
///   • PDF icon with red accent
///   • File name
///   • Date added (formatted as DD MMM YYYY)
///   • Favorite toggle button
///   • Delete button
class PdfFileTile extends StatelessWidget {
  const PdfFileTile({
    super.key,
    required this.file,
    required this.onDelete,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final LibraryFileModel file;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  String get _formattedDate {
    final d = file.createdAt;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding * 2.4,
          AppDimens.xs,
          AppDimens.screenPadding,
          AppDimens.xs,
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
              color: AppColors.error.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.md),

          // File name + date
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
                  'Added $_formattedDate',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Favorite button
          if (onFavoriteToggle != null)
            IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFavorite ? AppColors.warning : AppColors.textTertiary,
                size: AppDimens.iconMd,
              ),
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: AppDimens.iconMd,
            ),
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    ),
  );
}
}
