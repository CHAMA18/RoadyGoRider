import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import 'home_map_screen.dart';
import 'ride_checkout_screen.dart';
import 'wallet_screen.dart';

class RideHomeScreen extends StatefulWidget {
  const RideHomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<RideHomeScreen> createState() => _RideHomeScreenState();
}

class _RideHomeScreenState extends State<RideHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPromoDismissed = true;

  @override
  void initState() {
    super.initState();
    _loadPromoState();
  }

  Future<void> _loadPromoState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isPromoDismissed = prefs.getBool('isPromoDismissed') ?? false;
      });
    } catch (e) {
      debugPrint('Failed to load promo state: $e');
      setState(() {
        _isPromoDismissed = false;
      });
    }
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _navigate(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _handleLogout() {
    Navigator.of(context).pop();
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onLogout();
  }

  void _openPromo() async {
    final message = "Customer Wallet Top"; // From screenshot 1
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPromoDismissed', true);
    } catch (e) {
      debugPrint('Failed to save promo state: $e');
    }
    setState(() {
      _isPromoDismissed = true;
    });

    await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenPromoScreen(message: message);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: QuickJumpMenu(onNavigate: _navigate, onLogout: _handleLogout),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: MapBackdrop()),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Top Menu Button
                Positioned(
                  top: 36,
                  left: 20,
                  child: FloatingButton(
                    icon: Icons.menu,
                    dot: true,
                    onTap: _openDrawer,
                  ),
                ),
                // Top up Wallet Button
                Positioned(
                  top: 36,
                  right: 20,
                  child: PillButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: context.tr(AppStrings.topUpWallet),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                  ),
                ),
                // Promo Card
                if (!_isPromoDismissed)
                  Positioned(
                    top: 122,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _openPromo,
                      child: PromoCard(
                        message: "Customer Wallet Top",
                      ),
                    ),
                  ),
                // Bottom Panel
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.15],
                        colors: [
                          colorScheme.surface.withValues(alpha: 0.0),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        30,
                        0,
                        MediaQuery.paddingOf(context).bottom > 0
                            ? MediaQuery.paddingOf(context).bottom
                            : 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Order Now Section
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (_, __, ___) => HomeMapScreen(
                                    onLogout: widget.onLogout,
                                  ),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/IMG_0185.jpg',
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Order now',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: colorScheme.onSurface,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Recent Places Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _buildAddButton(theme),
                                const SizedBox(width: 12),
                                _buildPlaceChip(theme, 'Salama-park'),
                                const SizedBox(width: 12),
                                _buildPlaceChip(theme, 'Lusaka'),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // Just navigate to ride checkout for now
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RideCheckoutScreen(),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPlaceChip(ThemeData theme, String label) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RideCheckoutScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
