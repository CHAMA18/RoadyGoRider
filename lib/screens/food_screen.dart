import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF020617)
        : const Color(0xFFF7F4EE);
    final card = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -60,
              child: _BlurBubble(
                color: const Color(0xFFFFD36B),
                size: 240,
                opacity: isDark ? 0.08 : 0.22,
              ),
            ),
            Positioned(
              top: 120,
              right: -80,
              child: _BlurBubble(
                color: const Color(0xFFFF7A59),
                size: 260,
                opacity: isDark ? 0.10 : 0.18,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Row(
                    children: [
                      _FoodCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 14),
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
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Exceptional meals delivered around Lusaka in minutes.',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _FoodCircleButton(icon: Icons.tune_rounded, onTap: () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.16 : 0.06,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1E8),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'DELIVER TO',
                                      style: TextStyle(
                                        color: Color(0xFFD94F0B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.9,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Lusaka',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Fast picks, premium kitchens, zero hassle.',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const _DeliveryOrb(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _SearchFoodBar(),
                      const SizedBox(height: 18),
                      const _FeaturedFoodCard(),
                      const SizedBox(height: 22),
                      _SectionHeader(
                        title: 'Curated for you',
                        trailing: 'See all',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            _CuisineChip(
                              label: 'Trending',
                              selected: true,
                              icon: Icons.auto_awesome_rounded,
                            ),
                            SizedBox(width: 10),
                            _CuisineChip(
                              label: 'Burgers',
                              icon: Icons.lunch_dining_rounded,
                            ),
                            SizedBox(width: 10),
                            _CuisineChip(
                              label: 'Local',
                              icon: Icons.rice_bowl_rounded,
                            ),
                            SizedBox(width: 10),
                            _CuisineChip(
                              label: 'Pizza',
                              icon: Icons.local_pizza_rounded,
                            ),
                            SizedBox(width: 10),
                            _CuisineChip(
                              label: 'Desserts',
                              icon: Icons.icecream_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _RestaurantCard(
                        title: 'Flame Grill Social',
                        subtitle: 'Burgers • Bowls • Grill',
                        eta: '12-18 min',
                        rating: '4.9',
                        accent: Color(0xFFFF7A59),
                        surface: Color(0xFFFFF4EF),
                      ),
                      const SizedBox(height: 14),
                      const _RestaurantCard(
                        title: 'Copper Pot Kitchen',
                        subtitle: 'Zambian • Soul Food',
                        eta: '15-22 min',
                        rating: '4.8',
                        accent: Color(0xFFFFB703),
                        surface: Color(0xFFFFF7E1),
                      ),
                      const SizedBox(height: 14),
                      const _RestaurantCard(
                        title: 'Midnight Dough',
                        subtitle: 'Pizza • Sides • Desserts',
                        eta: '18-25 min',
                        rating: '4.7',
                        accent: Color(0xFF2A9D8F),
                        surface: Color(0xFFEFFBF8),
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(
                        title: 'Quick reorder',
                        trailing: 'Last 30 days',
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE7ECF2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFEDD5),
                                    Color(0xFFFFF7ED),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.ramen_dining_rounded,
                                color: Color(0xFFD94F0B),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chicken bowl combo',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Flame Grill Social • Ordered 3 times',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF25E1C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: HomeIndicator(),
                ),
              ],
            ),
          ],
        ),
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
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE7ECF2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
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

class _DeliveryOrb extends StatelessWidget {
  const _DeliveryOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      height: 94,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A3D), Color(0xFFF25E1C)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF25E1C).withValues(alpha: 0.24),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Positioned(
            top: 16,
            right: 18,
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white70,
            ),
          ),
          Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 42),
        ],
      ),
    );
  }
}

class _SearchFoodBar extends StatelessWidget {
  const _SearchFoodBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE7ECF2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 12),
          Text(
            'Search dishes, stores or cravings',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedFoodCard extends StatelessWidget {
  const _FeaturedFoodCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF22140D), Color(0xFF4A1F0E), Color(0xFFF25E1C)],
          stops: [0.0, 0.52, 1.0],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'CHEF\'S SPOTLIGHT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Late-night comfort food,\ncrafted like a premium drop.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Fresh kitchens. Smart curation. Delivery that feels concierge-level.',
                  style: TextStyle(
                    color: Color(0xFFFFE8DE),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Explore featured kitchens',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const _FoodArtPlate(),
        ],
      ),
    );
  }
}

class _FoodArtPlate extends StatelessWidget {
  const _FoodArtPlate();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 156,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 6,
            bottom: 0,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 6,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 74,
                height: 106,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFE8A3), Color(0xFFFFB347)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 4,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    top: 22,
                    child: Container(
                      width: 66,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9A3D),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 42,
                    child: Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A4B27),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 58,
                    child: Container(
                      width: 54,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A9D8F),
                        borderRadius: BorderRadius.circular(999),
                      ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: isDark ? const Color(0xFFFFB089) : const Color(0xFFD94F0B),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CuisineChip extends StatelessWidget {
  const _CuisineChip({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF25E1C)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFFF25E1C) : const Color(0xFFE7ECF2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : const Color(0xFFD94F0B),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
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
  const _RestaurantCard({
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.rating,
    required this.accent,
    required this.surface,
  });

  final String title;
  final String subtitle;
  final String eta;
  final String rating;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surface, Colors.white],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 16,
                  child: Container(
                    width: 56,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 64,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
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
                  children: [
                    Expanded(
                      child: Text(
                        title,
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD94F0B),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Color(0xFFD94F0B),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 15,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            eta,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Free delivery above ZMW 120',
                      softWrap: true,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
