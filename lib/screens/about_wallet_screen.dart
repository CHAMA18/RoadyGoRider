import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class AboutWalletScreen extends StatelessWidget {
  const AboutWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              title: context.tr(AppStrings.aboutWallet),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Your Wallet allows you to add funds for quicker checkouts and easy management of your trips and orders. You can top up using various payment methods, check your balance, and view your transaction history.\n\nWith default tips, you can set a predefined tip amount that applies to your rides automatically. Keeping funds in your wallet ensures a seamless and cashless experience.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr(AppStrings.continueLabel) ?? 'Continue', // We should check if continueLabel exists in AppStrings
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
