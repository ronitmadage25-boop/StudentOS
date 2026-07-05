import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';
import '../models/models.dart';
import 'pdf_file_tile.dart';

/// An expandable tile representing a category (PYQs, Notes, Important Questions).
///
/// Phase 5B: Tapping reveals the imported PDF list with an "Add PDF" button.
/// Phase 5D: Passes favorite IDs and callback for favorite toggling.
///
/// Displayed indented inside a [SubjectTile] when the subject is expanded.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.files,
    required this.onAddPdf,
    required this.onDeletePdf,
    required this.onTapPdf,
    this.favoriteIds = const [],
    this.onFavoriteToggle,
  });

  final LibraryCategoryModel category;
  final bool isExpanded;
  final VoidCallback onToggle;

  /// All PDF files in this category (already filtered by caller).
  final List<LibraryFileModel> files;

  final VoidCallback onAddPdf;
  final void Function(LibraryFileModel file) onDeletePdf;
  final void Function(LibraryFileModel file) onTapPdf;
  final List<String> favoriteIds;
  final void Function(LibraryFileModel file)? onFavoriteToggle;

  Color get _iconColor {
    switch (category.category) {
      case LibraryCategory.pyqs:
        return AppColors.error;
      case LibraryCategory.notes:
        return AppColors.primaryBlue;
      case LibraryCategory.importantQuestions:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _iconColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding * 2.4,
              AppDimens.xs + 2,
              AppDimens.screenPadding,
              AppDimens.xs + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Icon(category.icon, color: color, size: 16),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (files.isNotEmpty) ...[
                        const SizedBox(width: AppDimens.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${files.length}',
                            style: AppTextStyles.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: AppDimens.iconSm,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expanded PDF list ────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PDF file tiles
                    ...files.map(
                      (f) => PdfFileTile(
                        key: ValueKey(f.id),
                        file: f,
                        isFavorite: favoriteIds.contains(f.id),
                        onDelete: () => onDeletePdf(f),
                        onTap: () => onTapPdf(f),
                        onFavoriteToggle: onFavoriteToggle != null
                            ? () => onFavoriteToggle!(f)
                            : null,
                      ),
                    ),

                    // Add PDF button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.screenPadding * 2.4,
                        AppDimens.xs,
                        AppDimens.screenPadding,
                        AppDimens.sm,
                      ),
                      child: InkWell(
                        onTap: onAddPdf,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.md,
                            vertical: AppDimens.sm,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusMd),
                            border: Border.all(
                              color: color.withValues(alpha: 0.25),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, color: color, size: 16),
                              const SizedBox(width: AppDimens.xs),
                              Text(
                                'Add PDF',
                                style: AppTextStyles.caption.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
