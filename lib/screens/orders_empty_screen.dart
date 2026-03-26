import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class OrdersEmptyScreen extends StatelessWidget {
  const OrdersEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: const [
            TopBar(),
            Spacer(),
            EmptyOrdersIllustration(),
            SizedBox(height: 12),
            _OrdersEmptyText(),
            Spacer(),
            HomeIndicator(),
          ],
        ),
      ),
    );
  }
}

class _OrdersEmptyText extends StatelessWidget {
  const _OrdersEmptyText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr(AppStrings.noOrdersYet),
          style: const TextStyle(
            fontSize: AppTypography.size,
            color: AppColors.slate,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr(AppStrings.historyIsToMake),
          style: const TextStyle(
            fontSize: AppTypography.size,
            color: AppColors.slate,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class EmptyOrdersIllustration extends StatelessWidget {
  const EmptyOrdersIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.alt_route, color: Colors.white70, size: 36),
        ),
      ],
    );
  }
}
