import 'package:flutter/material.dart';

import '../app/localization.dart';
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
          children: [
            TopBar(
              title: context.tr(AppStrings.savedPlaces),
              trailing: context.tr(AppStrings.addAPlace),
            ),
            Spacer(),
            const SavedPlacesEmpty(),
            SizedBox(height: 12),
            Text(
              context.tr(AppStrings.saveYourFavoritePlaces),
              style: const TextStyle(
                color: AppColors.slate,
                fontSize: AppTypography.size,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const HomeIndicator(),
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
