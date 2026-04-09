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
import 'ride_home_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
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
  String? _recentLocation;
  bool _showCategories = false;

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

  Widget _buildOrderNowPanel(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('orderNow'),
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showCategories = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCategories = true;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildPlaceChip(ThemeData theme, String label) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
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
                      padding: EdgeInsets.fromLTRB(0, 30, 0, MediaQuery.paddingOf(context).bottom > 0 ? MediaQuery.paddingOf(context).bottom : 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _showCategories
                                ? HomeCategories(
                                    key: const ValueKey('categories'),
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
                                    onAddWork: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LocationPickerSheet(),
                                        ),
                                      );
                                      if (result != null && result is String && mounted) {
                                        setState(() {
                                          _recentLocation = result;
                                        });
                                      }
                                    },
                                    recentLocation: _recentLocation,
                                  )
                                : _buildOrderNowPanel(theme, colorScheme),
                          ),
                          const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
    this.recentLocation,
  });

  final VoidCallback onFoodTap;
  final VoidCallback onRideTap;
  final VoidCallback onAddWork;
  final String? recentLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        CategoryRow(
          label: context.tr(AppStrings.ride),
          leading: const SizedBox(
            width: 40,
            height: 30,
            child: RideCategoryIcon(),
          ),
          onTap: onRideTap,
          showTopBorder: true,
        ),
        CategoryRow(
          label: context.tr(AppStrings.food),
          leading: const SizedBox(
            width: 40,
            height: 30,
            child: FoodCategoryIcon(),
          ),
          onTap: onFoodTap,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onAddWork,
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: recentLocation == null ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: recentLocation != null ? BorderRadius.circular(30) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.24 : 0.06,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                  if (recentLocation != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      recentLocation!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
    return Image.asset('assets/images/PHOTO-2026-03-27-20-08-38.jpg', fit: BoxFit.contain);
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
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
            SizedBox(width: 44, child: Center(child: leading)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward,
              size: 20,
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

class _QuickJumpMenuState extends State<QuickJumpMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: MediaQuery.paddingOf(context).top + 28,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerRow(
            icon: Icons.grid_view_rounded,
            label: 'Services',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) => HomeMapScreen(onLogout: widget.onLogout),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          DrawerRow(
            icon: Icons.person_outline_rounded,
            label: context.tr(AppStrings.profile),
            onTap: () =>
                widget.onNavigate(ProfileScreen(onLogout: widget.onLogout)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, color: Color(0xFFF4B400), size: 16),
                SizedBox(width: 6),
                Text(
                  '4.90',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.slate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          DrawerRow(
            icon: Icons.notifications_none_rounded,
            label: context.tr(AppStrings.notifications),
            onTap: () => widget.onNavigate(const NotificationsScreen()),
          ),
          DrawerRow(
            icon: Icons.account_balance_wallet_outlined,
            label: context.tr(AppStrings.wallet),
            onTap: () => widget.onNavigate(const WalletScreen()),
            trailing: const Text(
              '0 ZMW',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DrawerRow(
            icon: Icons.map_outlined,
            label: context.tr(AppStrings.myOrders),
            onTap: () => widget.onNavigate(const OrdersEmptyScreen()),
          ),
          DrawerRow(
            icon: Icons.local_offer_outlined,
            label: context.tr(AppStrings.promo),
            onTap: () => widget.onNavigate(const PromoScreen()),
          ),
          DrawerRow(
            icon: Icons.settings_outlined,
            label: context.tr(AppStrings.settings),
            onTap: () => widget.onNavigate(const SettingsScreen()),
          ),
          const Spacer(),
          DrawerRow(
            icon: Icons.directions_car_outlined,
            label: context.tr(AppStrings.becomeADriver),
            onTap: () {},
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
