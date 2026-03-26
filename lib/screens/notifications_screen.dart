import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Notice(
        date: 'Mar 12',
        title: context.tr(AppStrings.happyYouthDay),
        isNew: true,
      ),
      _Notice(
        date: 'Mar 11',
        title: context.tr(AppStrings.freeConcertTickets),
        isNew: true,
      ),
      _Notice(date: 'Mar 6', title: context.tr(AppStrings.marchPromos)),
      _Notice(
        date: 'Jan 26',
        title: context.tr(AppStrings.dontAidFraud),
        isNew: true,
      ),
      _Notice(
        date: 'Dec 9, 2025',
        title: context.tr(AppStrings.freeTrip),
        isNew: true,
      ),
    ];
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
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final item = items[index];
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
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    context.tr(AppStrings.newBadge),
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
