import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';
import 'coupons_screen.dart';
import 'invite_friends_screen.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

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
            TopBar(title: context.tr(AppStrings.promo)),
            SimpleRow(
              icon: Icons.confirmation_number_outlined,
              label: context.tr(AppStrings.yourCoupons),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CouponsScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: dividerColor),
            SimpleRow(
              icon: Icons.person_add_alt_outlined,
              label: context.tr(AppStrings.inviteFriends),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const InviteFriendsScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: dividerColor),
            const Spacer(),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}

class SimpleRow extends StatelessWidget {
  const SimpleRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, size: 26),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: AppTypography.size,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
