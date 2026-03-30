import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/location_picker_sheet.dart';
import 'food_screen.dart';
import 'notifications_screen.dart';
import 'orders_empty_screen.dart';
import 'ride_checkout_screen.dart';
import 'wallet_screen.dart';
import 'profile_edit_screen.dart';
import 'settings_screen.dart';
import 'promo_screen.dart';

const _googleMapsApiKeyFallback = 'AIzaSyBzid8PyPK9S_eY3ymZLYo-iBNB01ShJYs';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPromoDismissed = true; // start as true until loaded

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
        _isPromoDismissed = false; // default if fail
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
    _logoutToAuth();
  }

  void _logoutToAuth() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onLogout();
  }

  void _openPromo() async {
    final message = context.tr(AppStrings.dontAidFraud);
    
    // Mark as dismissed immediately when clicked
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
            child: Stack(
              children: [
                Positioned(
                  top: 36,
                  left: 20,
                  child: FloatingButton(
                    icon: Icons.menu,
                    dot: true,
                    onTap: _openDrawer,
                  ),
                ),
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
                if (!_isPromoDismissed)
                  Positioned(
                    top: 122,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _openPromo,
                      child: PromoCard(
                        message: context.tr(AppStrings.dontAidFraud),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.26 : 0.08,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HomeCategories(
                            onRideTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RideCheckoutScreen(),
                              ),
                            ),
                            onFoodTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FoodScreen(),
                              ),
                            ),
                            onAddWork: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LocationPickerSheet(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const HomeIndicator(),
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
}

class MapBackdrop extends StatelessWidget {
  const MapBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned.fill(child: GoogleMapView()),
        Positioned(left: 34, bottom: 188, child: CarMarker()),
        Positioned(right: 104, bottom: 242, child: UserMarker()),
        Positioned(left: 34, bottom: 260, child: MapLabel()),
      ],
    );
  }
}

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  GoogleMapController? _controller;
  LatLng _initialTarget = const LatLng(-15.4067, 28.2871);
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _initialTarget = target;
          _initialized = true;
        });
        _controller?.animateCamera(CameraUpdate.newLatLng(target));
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _controller = controller,
      initialCameraPosition: CameraPosition(target: _initialTarget, zoom: 14.6),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      padding: const EdgeInsets.only(bottom: 300, top: 80),
    );
  }
}

class GoogleStaticMap extends StatelessWidget {
  const GoogleStaticMap({super.key, required this.center});

  final LatLng center;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    final resolvedApiKey = apiKey.isEmpty ? _googleMapsApiKeyFallback : apiKey;
    if (resolvedApiKey.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF2F4F7),
        alignment: Alignment.center,
        child: Text(
          context.tr(AppStrings.addMapsApiKey),
          style: const TextStyle(
            color: AppColors.slate,
            fontSize: AppTypography.size,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final url =
        'https://maps.googleapis.com/maps/api/staticmap?center=${center.latitude},${center.longitude}'
        '&zoom=14&size=900x1400&maptype=roadmap&key=$resolvedApiKey';
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF2F4F7),
        alignment: Alignment.center,
        child: Text(
          context.tr(AppStrings.mapFailedToLoad),
          style: TextStyle(
            color: AppColors.slate,
            fontSize: AppTypography.size,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class MapLabel extends StatelessWidget {
  const MapLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      'IBEX\nMEANWOOD',
      style: TextStyle(
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
        fontSize: AppTypography.size,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }
}

class CarMarker extends StatelessWidget {
  const CarMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 24,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class UserMarker extends StatelessWidget {
  const UserMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.icon,
    this.dot = false,
    this.onTap,
  });

  final IconData icon;
  final bool dot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.onSurface, size: 26),
          ),
          if (dot)
            Positioned(
              top: 11,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
              ),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onSurface),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: AppTypography.size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  const PromoCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'promo_icon',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.volume_off_rounded,
                size: 28,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Hero(
              tag: 'promo_text',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTypography.size,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenPromoScreen extends StatelessWidget {
  const FullScreenPromoScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 32),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'promo_icon',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.volume_off_rounded,
                        size: 56,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Hero(
                    tag: 'promo_text',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Please stay alert and report any suspicious activity. We are committed to your safety and well-being.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Understood', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCategoryCard extends StatelessWidget {
  const BigCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: icon,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
    required this.onFoodTap,
    required this.onRideTap,
    required this.onAddWork,
  });

  final VoidCallback onFoodTap;
  final VoidCallback onRideTap;
  final VoidCallback onAddWork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: BigCategoryCard(
                title: context.tr(AppStrings.ride),
                icon: const RideCategoryIcon(),
                onTap: onRideTap,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BigCategoryCard(
                title: context.tr(AppStrings.food),
                icon: const FoodCategoryIcon(),
                onTap: onFoodTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: onAddWork,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.24 : 0.10,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  size: 22,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAddWork,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.24 : 0.10,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.work_outline_rounded,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.tr(AppStrings.addWork),
                      style: TextStyle(
                        fontSize: AppTypography.size,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RideCategoryIcon extends StatelessWidget {
  const RideCategoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Image.asset(
        'assets/images/IMG_0185.jpg',
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
      ),
    );
  }
}

class FoodCategoryIcon extends StatelessWidget {
  const FoodCategoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 60,
      child: Image.asset(
        'assets/images/PHOTO-2026-03-27-20-08-38.jpg',
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
      ),
    );
  }
}



class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
    this.showTopBorder = false,
  });

  final String label;
  final Widget leading;
  final VoidCallback onTap;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE7E7E7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: theme.colorScheme.surface).copyWith(
          border: Border(
            bottom: BorderSide(color: dividerColor),
            top: showTopBorder
                ? BorderSide(color: dividerColor)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 28, child: Center(child: leading)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: AppTypography.size,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickJumpMenu extends StatefulWidget {
  const QuickJumpMenu({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  final void Function(Widget page) onNavigate;
  final VoidCallback onLogout;

  @override
  State<QuickJumpMenu> createState() => _QuickJumpMenuState();
}

enum _DrawerSection { account, activity }

class _QuickJumpMenuState extends State<QuickJumpMenu> {
  _DrawerSection _section = _DrawerSection.account;

  // The date the Wallet feature was added.
  static final DateTime _walletFeatureAddedDate = DateTime(2025, 5, 29); 

  bool get _showWalletNewBadge {
    // Show 'New' badge only if within 30 days of addition
    return DateTime.now().difference(_walletFeatureAddedDate).inDays <= 30;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountRows = [
      DrawerRow(
        icon: Icons.person_outline_rounded,
        label: context.tr(AppStrings.profile),
        onTap: () =>
            widget.onNavigate(ProfileEditScreen(onLogout: widget.onLogout)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.star, color: Color(0xFFF4B400), size: 18),
            SizedBox(width: 6),
            Text(
              '4.90',
              style: TextStyle(
                fontSize: AppTypography.size,
                color: AppColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      DrawerRow(
        icon: Icons.account_balance_wallet_outlined,
        label: context.tr(AppStrings.wallet),
        onTap: () => widget.onNavigate(const WalletScreen()),
        trailing: _showWalletNewBadge
            ? DrawerPill(
                label: context.tr(AppStrings.newBadge),
                background: const Color(0xFF16A34A),
              )
            : null,
      ),
      DrawerRow(
        icon: Icons.settings_outlined,
        label: context.tr(AppStrings.settings),
        onTap: () => widget.onNavigate(const SettingsScreen()),
      ),
    ];
    final activityRows = [
      DrawerRow(
        icon: Icons.notifications_none_rounded,
        label: context.tr(AppStrings.notifications),
        onTap: () => widget.onNavigate(const NotificationsScreen()),
        dot: true,
      ),
      DrawerRow(
        icon: Icons.menu_book_outlined,
        label: context.tr(AppStrings.myOrders),
        onTap: () => widget.onNavigate(const OrdersEmptyScreen()),
      ),
      DrawerRow(
        icon: Icons.local_offer_outlined,
        label: context.tr(AppStrings.promo),
        onTap: () => widget.onNavigate(const PromoScreen()),
      ),
    ];
    final visibleRows = _section == _DrawerSection.account
        ? accountRows
        : activityRows;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            context.tr(AppStrings.quickAccess),
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF94A3B8)
                  : AppColors.slate,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 2;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: _section == _DrawerSection.account ? 0 : tabWidth,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _section = _DrawerSection.account);
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: _section == _DrawerSection.account
                                      ? (theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : AppColors.slate)
                                      : (theme.brightness == Brightness.dark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                  fontSize: 14,
                                  fontWeight: _section == _DrawerSection.account
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                                child: Text(context.tr(AppStrings.account)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _section = _DrawerSection.activity);
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: _section == _DrawerSection.activity
                                      ? (theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : AppColors.slate)
                                      : (theme.brightness == Brightness.dark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                  fontSize: 14,
                                  fontWeight: _section == _DrawerSection.activity
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                                child: Text(context.tr(AppStrings.activity)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          ...visibleRows,
          const Spacer(),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr(AppStrings.signOut),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(context.tr(AppStrings.go)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class DrawerRow extends StatelessWidget {
  const DrawerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.dot = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool dot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 10 : 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 26, color: theme.colorScheme.onSurface),
                if (dot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 16 : AppTypography.size,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class DrawerPill extends StatelessWidget {
  const DrawerPill({super.key, required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppTypography.size,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
