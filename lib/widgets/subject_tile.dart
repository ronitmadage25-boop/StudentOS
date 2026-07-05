import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';
import '../models/models.dart';
import '../services/library_service.dart';
import 'category_tile.dart';

/// Expandable tile for a Subject folder inside a semester.
///
/// Phase 5B: Passes PDF file data + add/delete callbacks down into each
/// [CategoryTile] so users can import PDFs directly from this tile.
/// Phase 5D: Passes favorite IDs and toggle callback for favorites support.
class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.isExpanded,
    required this.expandedCategories,
    required this.allFiles,
    required this.onToggle,
    required this.onCategoryToggle,
    required this.onRename,
    required this.onDelete,
    required this.onAddPdf,
    required this.onDeletePdf,
    required this.onTapPdf,
    this.favoriteIds = const [],
    this.onFavoriteToggle,
  });

  final LibrarySubject subject;
  final bool isExpanded;

  /// Set of category IDs currently expanded within this subject.
  final Set<String> expandedCategories;

  /// All PDF files loaded from service (will be filtered per category).
  final List<LibraryFileModel> allFiles;

  final VoidCallback onToggle;
  final void Function(String categoryId) onCategoryToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final void Function(LibraryCategoryModel category) onAddPdf;
  final void Function(LibraryFileModel file) onDeletePdf;
  final void Function(LibraryFileModel file) onTapPdf;
  final List<String> favoriteIds;
  final void Function(LibraryFileModel file)? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding,
              AppDimens.sm,
              AppDimens.md,
              AppDimens.sm,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppDimens.lg),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.menu_book_rounded
                        : Icons.book_outlined,
                    color: AppColors.secondaryPurple,
                    size: AppDimens.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${subject.categories.length} categories',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: AppDimens.iconSm + 2,
                  ),
                ),
                // Options menu
                PopupMenuButton<_SubjectAction>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textTertiary,
                    size: AppDimens.iconSm,
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _SubjectAction.rename:
                        onRename();
                      case _SubjectAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _SubjectAction.rename,
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _SubjectAction.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            'Delete Subject',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Category children ─────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: subject.categories.map((cat) {
                      final catFiles = LibraryService.filesForCategory(
                        all: allFiles,
                        subjectId: subject.id,
                        category: cat.category,
                      );
                      final catExpanded =
                          expandedCategories.contains(cat.id);
                      return CategoryTile(
                        key: ValueKey('${subject.id}-${cat.id}'),
                        category: cat,
                        isExpanded: catExpanded,
                        onToggle: () => onCategoryToggle(cat.id),
                        files: catFiles,
                        favoriteIds: favoriteIds,
                        onAddPdf: () => onAddPdf(cat),
                        onDeletePdf: onDeletePdf,
                        onTapPdf: onTapPdf,
                        onFavoriteToggle: onFavoriteToggle,
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

enum _SubjectAction { rename, delete }
