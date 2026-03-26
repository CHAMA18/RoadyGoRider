import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
        
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(title: context.tr(AppStrings.notifications)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications',
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: dividerColor),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      
                      final title = data['title'] as String? ?? 'Notification';
                      final isNew = data['isNew'] as bool? ?? false;
                      final createdAt = data['createdAt'];
                      
                      DateTime? date;
                      if (createdAt is Timestamp) {
                        date = createdAt.toDate();
                      } else if (createdAt is String) {
                        date = DateTime.tryParse(createdAt);
                      }
                      
                      String dateStr = '';
                      if (date != null) {
                        final now = DateTime.now();
                        if (date.year == now.year) {
                          dateStr = DateFormat('MMM d').format(date);
                        } else {
                          dateStr = DateFormat('MMM d, yyyy').format(date);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: AppColors.slate,
                                    fontSize: AppTypography.size,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (isNew)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        color: Colors.red,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.tr(AppStrings.newBadge),
                                        style: const TextStyle(
                                          color: AppColors.slate,
                                          fontSize: AppTypography.size,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: AppTypography.size,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
