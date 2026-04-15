import 'dart:async';
import 'package:flutter/material.dart';
import '../app/app.dart';
import 'store_listing_screen.dart';
import 'restaurant_detail_screen.dart';
import 'saved_places_screen.dart';
import 'language_screen.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _restaurants = [
    {
      'title': 'PIZZA INN NOVARE MALL',
      'rating': '5',
      'deliveryFee': 'K 39',
      'timeText': '2 min.',
      'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=600&auto=format&fit=crop',
      'logoText': 'PI',
    },
    {
      'title': 'PIZZA INN LEVY MALL',
      'rating': '4.8',
      'deliveryFee': 'K 45',
      'timeText': '5 min.',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=600&auto=format&fit=crop',
      'logoText': 'PI',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 3 ? Colors.grey.shade50 : Colors.white,
      body: SafeArea(
        child: _currentIndex == 3 
            ? const _FoodProfileBody() 
            : _currentIndex == 1 
                ? _FoodFavoritesBody(
                    onOrderPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ) 
                : _currentIndex == 2
                    ? _FoodOrdersBody(
                        onOrderPressed: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                      )
                    : _buildHomeBody(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return Column(
      children: [
            // Top App Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        'Lusaka, Zambia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/car_icon_final.png',
                            height: 16,
                            width: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.directions_car, size: 16),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search restaurants and stores',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.tune, color: Colors.black87, size: 20),
                  ],
                ),
              ),
            ),
            
            // Expanded Scrollable Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                children: [
                  // Banner Element
                  const _PromoCarousel(),
                  const SizedBox(height: 24),
                  
                  // Categories Carousel (4 items)
                  const _CategoriesCarousel(),
                  const SizedBox(height: 24),

                  // Section Title
                  const Text(
                    'Restaurants and stores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // List Items
                  ..._restaurants.where((restaurant) =>
                    restaurant['title']!.toLowerCase().contains(_searchQuery)
                  ).map((restaurant) => Column(
                    children: [
                      RestaurantItemWidget(
                        title: restaurant['title']!,
                        rating: restaurant['rating']!,
                        deliveryFee: restaurant['deliveryFee']!,
                        timeText: restaurant['timeText']!,
                        imageUrl: restaurant['imageUrl']!,
                        logoText: restaurant['logoText']!,
                      ),
                      const SizedBox(height: 24),
                    ],
                  )),
                ],
              ),
            ),
          ],
        );
  }
}

class RestaurantItemWidget extends StatefulWidget {
  final String title;
  final String rating;
  final String deliveryFee;
  final String timeText;
  final String imageUrl;
  final String logoText;

  const RestaurantItemWidget({
    Key? key,
    required this.title,
    required this.rating,
    required this.deliveryFee,
    required this.timeText,
    required this.imageUrl,
    required this.logoText,
  }) : super(key: key);

  @override
  State<RestaurantItemWidget> createState() => _RestaurantItemWidgetState();
}

class _RestaurantItemWidgetState extends State<RestaurantItemWidget> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              title: widget.title,
              rating: widget.rating,
              timeText: widget.timeText,
              imageUrl: widget.imageUrl,
            ),
          ),
        );
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    widget.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.red.shade900,
                      child: const Center(child: Icon(Icons.local_pizza, color: Colors.white24, size: 60)),
                    ),
                  ),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red.shade900.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Crazy Friday Promo overlay
            Positioned(
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CRAZY\nFriday!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.green,
                    child: const Text(
                      'GET ANY LARGE SIGNATURE PIZZA',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.black,
                    child: const Text(
                      'ONLY ON FRIDAYS!',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Price Tag
            Positioned(
              top: 24,
              left: 160,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'K99',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.timeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                widget.logoText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            widget.rating,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.pedal_bike, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            widget.deliveryFee,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'K 780 to get ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'free delivery',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }
}

class _CategoriesCarousel extends StatelessWidget {
  const _CategoriesCarousel();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {
        'title': 'Burgers',
        'imageUrl':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Pizza',
        'imageUrl':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Sushi',
        'imageUrl':
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Healthy',
        'imageUrl':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=200&q=80',
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(categories[index]['imageUrl']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['title']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PizzaInnBanner extends StatelessWidget {
  const _PizzaInnBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_retouching_natural, color: Colors.black87, size: 48),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PIZZA',
                style: TextStyle(
                  color: Color(0xFF009640), // Pizza green
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'INN',
                style: TextStyle(
                  color: Color(0xFFE31837), // Pizza red
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const Text(
            'must be the pizza',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FREE DELIVERY WITH PIZZA INN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodProfileBody extends StatefulWidget {
  const _FoodProfileBody();

  @override
  State<_FoodProfileBody> createState() => _FoodProfileBodyState();
}

class _FoodProfileBodyState extends State<_FoodProfileBody> {
  bool _isHealthyLifestyleActive = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top pattern background
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.white,
          child: const _FoodPatternBackground(),
        ),
        // Scrollable content
        Column(
          children: [
            const SizedBox(height: 72),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chungu',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+260 77 1406330',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildCard(
                            icon: Icons.monitor_heart_outlined,
                            title: 'I lead a healthy lifestyle',
                            subtitle: 'Activate to see protein/fat/carbohydrate\ncontent and calorie count',
                            trailing: Switch(
                              value: _isHealthyLifestyleActive,
                              onChanged: (v) {
                                setState(() {
                                  _isHealthyLifestyleActive = v;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                            iconColor: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            icon: Icons.location_on_outlined,
                            title: 'My addresses',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            iconColor: Colors.grey.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SavedPlacesScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            icon: Icons.confirmation_number_outlined,
                            title: 'My promo codes',
                            subtitle: '0 promo codes',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            iconColor: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            icon: Icons.language_outlined,
                            title: 'My language',
                            subtitle: LanguageScreen.languageMap[RoadyGoRiderApp.of(context).selectedLanguage] ?? RoadyGoRiderApp.of(context).selectedLanguage,
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            iconColor: Colors.grey.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LanguageScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            icon: Icons.phone_outlined,
                            title: 'Support',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            iconColor: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            icon: Icons.local_shipping_outlined,
                            title: 'About the platform',
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            iconColor: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 32),
                        ],
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    ),
  );
}
}

class _FoodPatternBackground extends StatelessWidget {
  const _FoodPatternBackground();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Opacity(
        opacity: 0.1,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(100, (index) {
            final icons = [
              Icons.fastfood_outlined,
              Icons.local_pizza_outlined,
              Icons.lunch_dining_outlined,
              Icons.icecream_outlined,
              Icons.cake_outlined,
              Icons.local_cafe_outlined,
              Icons.bakery_dining_outlined,
              Icons.ramen_dining_outlined,
              Icons.egg_outlined,
            ];
            return Transform.rotate(
              angle: (index * 0.3),
              child: Icon(
                icons[index % icons.length],
                size: 28,
                color: Colors.grey.shade800,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FoodFavoritesBody extends StatelessWidget {
  final VoidCallback onOrderPressed;

  const _FoodFavoritesBody({required this.onOrderPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: const Text(
            'Favorites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Transform.rotate(
                            angle: 0.2,
                            child: Icon(
                              Icons.takeout_dining_outlined,
                              size: 70,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 30,
                          child: Icon(
                            Icons.local_cafe_outlined,
                            size: 90,
                            color: Colors.black.withValues(alpha: 0.9),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 10,
                          child: Icon(
                            Icons.lunch_dining_outlined,
                            size: 110,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You Currently have no Favorites',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add restaurants and stores to Favorites\nand they will show up here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: onOrderPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF05B1E),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Order from catalog',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodOrdersBody extends StatelessWidget {
  final VoidCallback onOrderPressed;

  const _FoodOrdersBody({required this.onOrderPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Order history',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _EmptyOrdersIllustration(),
                  const SizedBox(height: 32),
                  const Text(
                    'You have no orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Place your first order and it will appear here.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: onOrderPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF05B1E),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Order from catalog',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyOrdersIllustration extends StatelessWidget {
  const _EmptyOrdersIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 200,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(160, 200),
            painter: _BagPainter(),
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconBox(Icons.storefront_outlined, accentColor: const Color(0xFFF05B1E)),
                    const SizedBox(width: 8),
                    _buildIconBox(Icons.lunch_dining_outlined, accentColor: const Color(0xFFF05B1E)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconBox(Icons.fastfood_outlined, accentColor: const Color(0xFFF05B1E)), 
                    const SizedBox(width: 8),
                    _buildIconBox(Icons.local_pizza_outlined, accentColor: const Color(0xFFF05B1E)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, {Color? accentColor}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (accentColor != null)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Icon(icon, color: Colors.black, size: 28),
        ],
      ),
    );
  }
}

class _BagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
      
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    final w = size.width;
    final h = size.height;
    
    // The main body is a rounded rect.
    final mainRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.05, h * 0.2, w * 0.95, h),
      const Radius.circular(20),
    );
    canvas.drawRRect(mainRect, bgPaint);
    canvas.drawRRect(mainRect, paint);
    
    // The top cap
    final capRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.25, h * 0.05, w * 0.75, h * 0.2),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );
    
    canvas.drawRRect(capRect, bgPaint);
    canvas.drawRRect(capRect, paint);
    
    // Handle hole inside the cap
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.38, h * 0.09, w * 0.62, h * 0.14),
      const Radius.circular(6),
    );
    canvas.drawRRect(handleRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Widget> _banners = [
    const _PizzaInnBanner(),
    const _ImageBanner(
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
      title: '50% OFF',
      subtitle: 'On all Burgers today!',
      color: Colors.orange,
    ),
    const _ImageBanner(
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=800&q=80',
      title: 'Fresh Sushi',
      subtitle: 'Delivered in 30 mins',
      color: Colors.redAccent,
    ),
    const _ImageBanner(
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
      title: 'Eat Fresh',
      subtitle: 'Healthy options for you',
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return _banners[index];
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.black87 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageBanner extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Color color;

  const _ImageBanner({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

