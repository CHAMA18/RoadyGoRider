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
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'An error occurred: ${snapshot.error}',
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

                  final docs = snapshot.data!.docs.toList();
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final dateA = dataA['createdAt'];
                    final dateB = dataB['createdAt'];
                    
                    DateTime timeA = DateTime.fromMillisecondsSinceEpoch(0);
                    DateTime timeB = DateTime.fromMillisecondsSinceEpoch(0);
                    
                    if (dateA is Timestamp) timeA = dateA.toDate();
                    else if (dateA is String) timeA = DateTime.tryParse(dateA) ?? timeA;
                    
                    if (dateB is Timestamp) timeB = dateB.toDate();
                    else if (dateB is String) timeB = DateTime.tryParse(dateB) ?? timeB;
                    
                    return timeB.compareTo(timeA); // descending
                  });

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

                      return InkWell(
                        onTap: () async {
                          final message = data['message'] ?? data['body'] ?? data['description'] ?? '';
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                content: SingleChildScrollView(
                                  child: Text(
                                    message.toString().isNotEmpty ? message.toString() : 'No additional content.',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      context.tr(AppStrings.done) ?? 'Done',
                                      style: TextStyle(color: theme.primaryColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          // After closing the dialog, remove the notification
                          try {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc(docs[index].id)
                                .delete();
                          } catch (e) {
                            debugPrint('Error deleting notification: $e');
                          }
                        },
                        child: Padding(
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
