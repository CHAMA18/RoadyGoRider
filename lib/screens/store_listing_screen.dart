import 'package:flutter/material.dart';

import 'cart_screen.dart';

class StoreListingScreen extends StatefulWidget {
  const StoreListingScreen({
    super.key,
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
  State<StoreListingScreen> createState() => _StoreListingScreenState();
}

class _StoreListingScreenState extends State<StoreListingScreen> {
  int _selectedCategoryIndex = 0;
  final List<CartItem> _cartItems = [];

  double get _cartTotal => _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get _cartCount => _cartItems.fold(0, (count, item) => count + item.quantity);

  void _addToCart(String id, String title, double price) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _cartItems[index].quantity++;
      } else {
        _cartItems.add(CartItem(id: id, title: title, price: price));
      }
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        if (_cartItems[index].quantity > 1) {
          _cartItems[index].quantity--;
        } else {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  int _getQuantity(String id) {
    final item = _cartItems.where((item) => item.id == id).firstOrNull;
    return item?.quantity ?? 0;
  }

  final List<String> _categories = [
    'Popular',
    'Burgers',
    'Bowls',
    'Drinks',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: widget.surface,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.surface,
                      isDark ? const Color(0xFF1E293B) : Colors.white,
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 40,
                      right: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -20,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.restaurant_rounded,
                      size: 80,
                      color: widget.accent.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: widget.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating,
                              style: TextStyle(
                                color: widget.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.access_time_filled_rounded,
                        widget.eta,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        context,
                        Icons.delivery_dining_rounded,
                        'Free delivery',
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.accent
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF475569)),
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _MenuItem(
                    id: 'item_${_categories[_selectedCategoryIndex]}_$index',
                    title: 'Signature ${_categories[_selectedCategoryIndex]} ${index + 1}',
                    description: 'Tender, juicy, and perfectly seasoned with our secret blend of spices. Served with a side of crispy fries.',
                    price: '₺ ${(85 + index * 15).toString()}',
                    numericPrice: (85 + index * 15).toDouble(),
                    accent: widget.accent,
                    isDark: isDark,
                    quantity: _getQuantity('item_${_categories[_selectedCategoryIndex]}_$index'),
                    onAdd: () => _addToCart(
                      'item_${_categories[_selectedCategoryIndex]}_$index',
                      'Signature ${_categories[_selectedCategoryIndex]} ${index + 1}',
                      (85 + index * 15).toDouble(),
                    ),
                    onRemove: () => _removeFromCart('item_${_categories[_selectedCategoryIndex]}_$index'),
                  );
                },
                childCount: 8,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
      if (_cartItems.isNotEmpty)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '₺ ${_cartTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: widget.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedCart = await Navigator.push<List<CartItem>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                            storeName: widget.title,
                            accent: widget.accent,
                            initialItems: List.from(_cartItems), // Clone list to avoid direct mutation
                          ),
                        ),
                      );
                      if (updatedCart != null) {
                        setState(() {
                          _cartItems.clear();
                          _cartItems.addAll(updatedCart);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Cart',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_cartCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _cartCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ]
                      ],
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: widget.accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.numericPrice,
    required this.accent,
    required this.isDark,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final double numericPrice;
  final Color accent;
  final bool isDark;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.fastfood_rounded,
                  size: 40,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
                Positioned(
                  bottom: -8,
                  child: quantity > 0
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: onRemove,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Icon(Icons.remove_rounded, size: 20, color: accent),
                                ),
                              ),
                              Text(
                                quantity.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: onAdd,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Icon(Icons.add_rounded, size: 20, color: accent),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 24,
                              color: accent,
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
