import 'package:flutter/material.dart';

import 'store_listing_screen.dart';
import '../widgets/common_widgets.dart';

class _RestaurantData {
  final String title;
  final String subtitle;
  final String eta;
  final String rating;
  final Color accent;
  final Color surface;
  final bool isCuratedOnly;

  const _RestaurantData({
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.rating,
    required this.accent,
    required this.surface,
    this.isCuratedOnly = false,
  });
}

const _allRestaurants = [
  _RestaurantData(
    title: 'Flame Grill Social',
    subtitle: 'Burgers • Bowls • Grill',
    eta: '12-18 min',
    rating: '4.9',
    accent: Color(0xFFF48261),
    surface: Color(0xFFFFF2ED),
  ),
  _RestaurantData(
    title: 'Copper Pot Kitchen',
    subtitle: 'Zambian • Soul Food',
    eta: '15-22 min',
    rating: '4.8',
    accent: Color(0xFFFFC033),
    surface: Color(0xFFFFFBF2),
  ),
  _RestaurantData(
    title: 'Midnight Dough',
    subtitle: 'Pizza • Sides • Desserts',
    eta: '18-25 min',
    rating: '4.7',
    accent: Color(0xFF2A9D8F),
    surface: Color(0xFFEFFFFB),
  ),
  _RestaurantData(
    title: 'Taco Haven',
    subtitle: 'Mexican • Tacos • Burritos',
    eta: '10-20 min',
    rating: '4.6',
    accent: Color(0xFFE76F51),
    surface: Color(0xFFFDECE8),
    isCuratedOnly: true,
  ),
  _RestaurantData(
    title: 'Sushi Master',
    subtitle: 'Japanese • Sushi • Seafood',
    eta: '20-35 min',
    rating: '4.9',
    accent: Color(0xFF8338EC),
    surface: Color(0xFFF3E8FD),
    isCuratedOnly: true,
  ),
  _RestaurantData(
    title: 'Green Bowl',
    subtitle: 'Healthy • Salads • Vegan',
    eta: '15-25 min',
    rating: '4.8',
    accent: Color(0xFF38B000),
    surface: Color(0xFFEAF8E6),
    isCuratedOnly: true,
  ),
];

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F5F7),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            left: -80,
            child: _BlurBubble(
              color: const Color(0xFFFDF0CD),
              size: 280,
              opacity: isDark ? 0.05 : 0.8,
            ),
          ),
          Positioned(
            top: 80,
            right: -100,
            child: _BlurBubble(
              color: const Color(0xFFFCE1D5),
              size: 300,
              opacity: isDark ? 0.05 : 0.7,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FoodCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Exceptional meals delivered around\nLusaka in minutes.',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF5E6F88),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _FoodCircleButton(
                        icon: Icons.tune_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      const _HeroCard(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Curated for you',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                color: Color(0xFFE25916),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: const [
                            _CategoryChip(
                              label: 'Trending',
                              icon: Icons.auto_awesome_rounded,
                              isSelected: true,
                            ),
                            SizedBox(width: 12),
                            _CategoryChip(
                              label: 'Burgers',
                              icon: Icons.lunch_dining_rounded,
                            ),
                            SizedBox(width: 12),
                            _CategoryChip(
                              label: 'Local',
                              icon: Icons.location_on_rounded,
                            ),
                            SizedBox(width: 12),
                            _CategoryChip(
                              label: 'Pizza',
                              icon: Icons.local_pizza_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._allRestaurants
                          .where((r) => !r.isCuratedOnly)
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => StoreListingScreen(
                                          title: r.title,
                                          subtitle: r.subtitle,
                                          eta: r.eta,
                                          rating: r.rating,
                                          accent: r.accent,
                                          surface: r.surface,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _RestaurantCard(data: r),
                                ),
                              )),
                    ],
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

class _FoodCircleButton extends StatelessWidget {
  const _FoodCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onSurface,
          size: 22,
        ),
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3E1D0D), Color(0xFFD65814)],
          stops: [0.1, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Late-night comfort\nfood,\ncrafted like a\npremium drop.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fresh kitchens. Smart curation.\nDelivery that feels concierge-\nlevel.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Explore featured kitchens',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: const _BurgerIllustration(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurgerIllustration extends StatelessWidget {
  const _BurgerIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Yellow background pill
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 70,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          // White circle
          Positioned(
            left: 0,
            bottom: 10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A261),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 64,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC76930),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 54,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A9D8F),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8581E) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE8581E)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : const Color(0xFFE8581E),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.data});

  final _RestaurantData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: data.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 14,
                  decoration: BoxDecoration(
                    color: data.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 48,
                  height: 18,
                  decoration: BoxDecoration(
                    color: data.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFE8581E),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.rating,
                            style: const TextStyle(
                              color: Color(0xFFE8581E),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color:
                        isDark ? const Color(0xFF94A3B8) : const Color(0xFF5E6F88),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: data.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.eta,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Free delivery above ₺ 120',
                  style: TextStyle(
                    color:
                        isDark ? const Color(0xFF94A3B8) : const Color(0xFF5E6F88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
