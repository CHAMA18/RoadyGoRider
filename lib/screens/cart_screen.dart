import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  final String storeName;
  final Color accent;
  final List<CartItem> initialItems;

  const CartScreen({
    super.key,
    required this.storeName,
    required this.accent,
    required this.initialItems,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _items;
  final double _deliveryFee = 25.0;

  @override
  void initState() {
    super.initState();
    // Copy the items to allow local mutation before returning
    _items = widget.initialItems
        .map((item) => CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              quantity: item.quantity,
            ))
        .toList();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _taxes => _subtotal * 0.1;
  double get _total => _subtotal + _deliveryFee + _taxes;

  void _incrementQuantity(int index) {
    setState(() {
      _items[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _items);
    return false; // Prevent default pop
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _items);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context, _items),
          ),
          title: Text(
            'View Cart',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: subtitleColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Looks like you haven\'t added\nanything to your cart yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _items),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Browse Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Delivery info card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.accent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: widget.accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ordering from',
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.storeName,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Your Items',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Simple colored placeholder instead of an image
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: widget.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.fastfood_rounded,
                                      color: widget.accent,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              Icons.close_rounded,
                                              size: 20,
                                              color: subtitleColor,
                                            ),
                                            onPressed: () => _removeItem(index),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₺ ${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: widget.accent,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _QuantityButton(
                                            icon: Icons.remove_rounded,
                                            color: subtitleColor,
                                            onTap: () => _decrementQuantity(index),
                                            isDark: isDark,
                                          ),
                                          Container(
                                            width: 40,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          _QuantityButton(
                                            icon: Icons.add_rounded,
                                            color: widget.accent,
                                            onTap: () => _incrementQuantity(index),
                                            isDark: isDark,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _items.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        children: [
                          // Add more button
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context, _items),
                            icon: Icon(Icons.add_circle_outline, color: widget.accent),
                            label: Text(
                              'Add more items',
                              style: TextStyle(
                                color: widget.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Promo code box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: dividerColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_offer_outlined, color: widget.accent, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Add a promo code',
                                      hintStyle: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 15,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: widget.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Bill details
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill Details',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _BillRow(
                                  title: 'Item Total',
                                  value: '₺ ${_subtotal.toStringAsFixed(2)}',
                                  textColor: subtitleColor,
                                ),
                                const SizedBox(height: 12),
                                _BillRow(
                                  title: 'Delivery Fee',
                                  value: '₺ ${_deliveryFee.toStringAsFixed(2)}',
                                  textColor: subtitleColor,
                                ),
                                const SizedBox(height: 12),
                                _BillRow(
                                  title: 'Taxes & Fees',
                                  value: '₺ ${_taxes.toStringAsFixed(2)}',
                                  textColor: subtitleColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(color: dividerColor),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Pay',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '₺ ${_total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _items.isEmpty
            ? null
            : Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: 20 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₺ ${_total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _items.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String title;
  final String value;
  final Color textColor;

  const _BillRow({
    required this.title,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuantityButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
