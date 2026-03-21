import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: const [
            TopBar(title: 'Saved places', trailing: 'Add a place'),
            Spacer(),
            SavedPlacesEmpty(),
            SizedBox(height: 12),
            Text(
              'Save your favorite places',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: AppTypography.size,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            HomeIndicator(),
          ],
        ),
      ),
    );
  }
}

class SavedPlacesEmpty extends StatelessWidget {
  const SavedPlacesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 14,
          child: Icon(
            Icons.place,
            size: 72,
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
          ),
        ),
        Positioned(
          left: 14,
          child: Icon(
            Icons.place,
            size: 72,
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
          ),
        ),
        Icon(
          Icons.place,
          size: 82,
          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
        ),
        Positioned(
          top: 22,
          child: Icon(
            Icons.star,
            size: 22,
            color: isDark ? const Color(0xFFE2E8F0) : Colors.black54,
          ),
        ),
      ],
    );
  }
}
