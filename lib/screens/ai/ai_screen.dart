import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../widgets/chat_bubble.dart';

/// AI Study Assistant interface with ChatGPT-style conversation simulator.
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        'message': 'Hello! I\'m your AI Study Assistant. How can I help you today? 📚',
        'isUser': false,
        'timestamp': '10:30 AM',
      },
      {
        'message': 'Can you explain Binary Search Trees?',
        'isUser': true,
        'timestamp': '10:31 AM',
      },
      {
        'message': 'Of course! A Binary Search Tree (BST) is a data structure where each node has at most two children. The left child contains values less than the parent, and the right child contains values greater than the parent.\n\nKey properties:\n• Each node has at most 2 children\n• Left subtree values < parent\n• Right subtree values > parent\n• Average time complexity: O(log n)',
        'isUser': false,
        'timestamp': '10:31 AM',
      },
      {
        'message': 'What about the worst case?',
        'isUser': true,
        'timestamp': '10:32 AM',
      },
      {
        'message': 'Great question! The worst case for a BST occurs when the tree becomes skewed (essentially a linked list). This happens when elements are inserted in sorted order.\n\nWorst case time complexity: O(n)\n\nTo avoid this, we use self-balancing BSTs like AVL trees or Red-Black trees.',
        'isUser': false,
        'timestamp': '10:32 AM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.aiTitle),
            Text(
              'Powered by AI',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(
                  message: msg['message'] as String,
                  isUser: msg['isUser'] as bool,
                  timestamp: msg['timestamp'] as String?,
                );
              },
            ),
          ),
          
          // Bottom Input Area
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
              vertical: AppDimens.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: const Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.lg,
                          vertical: AppDimens.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI responses coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBlue,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
