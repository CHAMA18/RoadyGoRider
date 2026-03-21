import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    _Notice(date: 'Mar 12', title: 'Happy Youth Day!', isNew: true),
    _Notice(date: 'Mar 11', title: 'Want Free Concert Tickets?', isNew: true),
    _Notice(date: 'Mar 6', title: 'March Promos'),
    _Notice(date: 'Jan 26', title: 'Don\'t Aid Fraud', isNew: true),
    _Notice(date: 'Dec 9, 2025', title: 'Win A Free Trip!', isNew: true),
  ];

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
            const TopBar(title: 'Notifications'),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final item = _items[index];
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
                              item.date,
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: AppTypography.size,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (item.isNew)
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'New',
                                    style: TextStyle(
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
                          item.title,
                          style: const TextStyle(
                            fontSize: AppTypography.size,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

class _Notice {
  const _Notice({required this.date, required this.title, this.isNew = false});

  final String date;
  final String title;
  final bool isNew;
}
