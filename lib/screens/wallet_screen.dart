import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';
import 'about_wallet_screen.dart';
import 'top_up_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? _selectedTipAmount;

  void _navigateToAboutWallet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutWalletScreen(),
      ),
    );
  }

  void _showCustomTipDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Tip'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter custom amount',
              prefixText: '\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _selectedTipAmount = '\$${controller.text}';
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTipBottomSheet() {
    final noTipStr = context.tr(AppStrings.noTip);
    // Include the standard options + custom
    final tipOptions = [
      noTipStr,
      '\$1',
      '\$2',
      '\$3',
      '\$4',
      '\$5',
      'Custom'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final dividerColor = theme.brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE5E7EB);
            
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(AppStrings.defaultTips),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: dividerColor),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tipOptions.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
                  itemBuilder: (context, index) {
                    final tip = tipOptions[index];
                    final currentTipStr = _selectedTipAmount ?? noTipStr;
                    
                    // The 'Custom' option logic
                    final isCustomSelected = tip == 'Custom' && 
                                           !['\$1', '\$2', '\$3', '\$4', '\$5', noTipStr].contains(currentTipStr);
                                           
                    final isSelected = tip == currentTipStr || isCustomSelected;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      title: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: theme.primaryColor)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (tip == 'Custom') {
                          _showCustomTipDialog();
                        } else {
                          setState(() {
                            _selectedTipAmount = tip == noTipStr ? null : tip;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
        
    final noTipStr = context.tr(AppStrings.noTip);
    final currentTipDisplay = _selectedTipAmount ?? noTipStr;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              title: context.tr(AppStrings.wallet),
              trailing: context.tr(AppStrings.aboutWallet),
              onTrailingTap: () => _navigateToAboutWallet(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TopUpScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$0.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            context.tr(AppStrings.topUp),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: dividerColor),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.savings_outlined, size: 28),
              title: Text(
                context.tr(AppStrings.defaultTips),
                style: const TextStyle(
                  fontSize: AppTypography.size,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Text(
                currentTipDisplay,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: AppTypography.size,
                ),
              ),
              onTap: _showTipBottomSheet,
            ),
            Divider(height: 1, color: dividerColor),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.receipt_long_outlined, size: 28),
              title: Text(
                context.tr(AppStrings.transactions),
                style: const TextStyle(
                  fontSize: AppTypography.size,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.slate),
              onTap: () {
                // TODO: Implement transactions view
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
