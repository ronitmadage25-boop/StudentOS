import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../widgets/section_header.dart';
import '../../widgets/profile_tile.dart';

/// User Profile screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimens.radiusXl),
                  bottomRight: Radius.circular(AppDimens.radiusXl),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimens.md),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Text(
                          'R',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text(
                        'Ronit',
                        style: AppTextStyles.heading2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        'Computer Engineering · Semester 3',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        'SPIT, Mumbai',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academic Overview Section
                  const SectionHeader(title: 'Academic Overview'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          'Attendance',
                          '82%',
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: _buildStatTile(
                          'CGPA',
                          '8.12',
                          AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: _buildStatTile(
                          'Subjects',
                          '6',
                          AppColors.secondaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Quick Actions Section
                  const SectionHeader(title: 'Quick Actions'),
                  ProfileTile(
                    title: 'Edit Profile',
                    subtitle: 'Update your personal details',
                    leading: Icons.edit_rounded,
                    leadingColor: AppColors.primaryBlue,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.md),
                  ProfileTile(
                    title: 'Notifications',
                    subtitle: 'Manage alerts & reminders',
                    leading: Icons.notifications_rounded,
                    leadingColor: AppColors.warning,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.md),
                  ProfileTile(
                    title: 'Download Reports',
                    subtitle: 'Get academic transcript PDFs',
                    leading: Icons.download_rounded,
                    leadingColor: AppColors.success,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Settings Section
                  const SectionHeader(title: 'Settings'),
                  ProfileTile(
                    title: 'Appearance',
                    subtitle: 'Theme & display mode settings',
                    leading: Icons.palette_rounded,
                    leadingColor: AppColors.secondaryPurple,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.md),
                  ProfileTile(
                    title: 'Language',
                    subtitle: 'English (US)',
                    leading: Icons.language_rounded,
                    leadingColor: AppColors.primaryBlue,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.md),
                  ProfileTile(
                    title: 'Help & Support',
                    subtitle: 'FAQs, tutorials & contact us',
                    leading: Icons.help_outline_rounded,
                    leadingColor: AppColors.info,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.md),
                  ProfileTile(
                    title: 'About StudentOS',
                    subtitle: 'Version 1.0.0 (Release build)',
                    leading: Icons.info_outline_rounded,
                    leadingColor: AppColors.textSecondary,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimens.huge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
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
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
