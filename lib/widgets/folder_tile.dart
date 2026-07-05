import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// Expandable tile for a Semester folder.
///
/// Displays the semester name, subject count, and hosts an expand/collapse
/// animation. Provides rename and delete actions via a popup menu.
class SemesterTile extends StatelessWidget {
  const SemesterTile({
    super.key,
    required this.semesterName,
    required this.subjectCount,
    required this.isExpanded,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    required this.onAddSubject,
    required this.children,
  });

  final String semesterName;
  final int subjectCount;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddSubject;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.cardPadding,
                vertical: AppDimens.md,
              ),
              child: Row(
                children: [
                  // Folder icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.folder_open_rounded
                          : Icons.folder_rounded,
                      color: AppColors.primaryBlue,
                      size: AppDimens.iconLg,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  // Name + count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(semesterName, style: AppTextStyles.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          '$subjectCount ${subjectCount == 1 ? "subject" : "subjects"}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  // Options menu
                  PopupMenuButton<_SemesterAction>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textTertiary,
                      size: AppDimens.iconSm + 2,
                    ),
                    onSelected: (action) {
                      switch (action) {
                        case _SemesterAction.addSubject:
                          onAddSubject();
                        case _SemesterAction.rename:
                          onRename();
                        case _SemesterAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _SemesterAction.addSubject,
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Add Subject'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: _SemesterAction.rename,
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
                        value: _SemesterAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
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
          ),
          // Children
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1),
                      ...children,
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

enum _SemesterAction { addSubject, rename, delete }
