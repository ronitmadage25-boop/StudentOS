import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_dimens.dart';

/// A reusable chat message bubble widget.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  final String message;
  final bool isUser;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg,
                vertical: AppDimens.md,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryBlue : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimens.radiusLg),
                  topRight: const Radius.circular(AppDimens.radiusLg),
                  bottomLeft: Radius.circular(
                    isUser ? AppDimens.radiusLg : AppDimens.radiusSm,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? AppDimens.radiusSm : AppDimens.radiusLg,
                  ),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: AppDimens.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
                child: Text(
                  timestamp!,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
