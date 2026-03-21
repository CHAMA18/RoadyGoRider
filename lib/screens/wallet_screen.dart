import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
            const TopBar(title: 'Wallet', trailing: 'About wallet'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Spacer(),
                    Icon(Icons.add, color: Colors.white, size: 30),
                    SizedBox(height: 10),
                    Text(
                      'Top up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.size,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: dividerColor),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.savings_outlined, size: 28),
              title: const Text(
                'Default tips',
                style: TextStyle(
                  fontSize: AppTypography.size,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Text(
                'No tip',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: AppTypography.size,
                ),
              ),
              onTap: () {},
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
