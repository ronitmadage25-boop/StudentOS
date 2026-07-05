import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';
import '../services/library_history_service.dart';

/// A card displaying library statistics overview.
///
/// Shows:
///   • Total PDFs
///   • Favorite PDFs
///   • Recently Opened PDFs
///   • Total Subjects
///
/// Uses a 2x2 grid layout with color-coded stat items.
class LibraryStatsCard extends StatelessWidget {
  const LibraryStatsCard({
    super.key,
    required this.stats,
  });

  final LibraryStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.md,
            crossAxisSpacing: AppDimens.md,
            childAspectRatio: 1.3,
            children: [
              _buildStatItem(
                icon: Icons.description_rounded,
                label: 'Total PDFs',
                value: stats.totalPdfs.toString(),
                color: AppColors.info,
              ),
              _buildStatItem(
                icon: Icons.star_rounded,
                label: 'Favorites',
                value: stats.totalFavorites.toString(),
                color: AppColors.warning,
              ),
              _buildStatItem(
                icon: Icons.history_rounded,
                label: 'Recently Opened',
                value: stats.totalRecent.toString(),
                color: AppColors.success,
              ),
              _buildStatItem(
                icon: Icons.book_rounded,
                label: 'Subjects',
                value: stats.totalSubjects.toString(),
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppDimens.xs),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
