import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../app/localization.dart';
import 'schedule_ride_sheet.dart';
import 'package:intl/intl.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  DateTime? _scheduledDate;
  
  // Dummy data for suggestions
  final List<Map<String, String>> _suggestions = [
    {
      'title': 'Levy Junction Shopping Mall',
      'subtitle': 'Church Rd, Lusaka',
      'icon': 'mall',
    },
    {
      'title': 'Zesco Limited Head Office',
      'subtitle': 'Great East Rd, Lusaka',
      'icon': 'office',
    },
    {
      'title': 'Thorn Park',
      'subtitle': 'Lusaka, Zambia',
      'icon': 'park',
    },
    {
      'title': 'Chilulu',
      'subtitle': 'Lusaka, Zambia',
      'icon': 'pin',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto focus the search field after the bottom sheet animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'mall':
        return Icons.local_mall_outlined;
      case 'office':
        return Icons.business_outlined;
      case 'park':
        return Icons.park_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * 0.92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.12],
          colors: [
            theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: colorScheme.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Where to?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<dynamic>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ScheduleRideSheet(
                        initialDate: _scheduledDate,
                      ),
                    );
                    if (result == 'now') {
                      setState(() => _scheduledDate = null);
                    } else if (result is DateTime) {
                      setState(() => _scheduledDate = result);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _scheduledDate != null
                              ? DateFormat('h:mm a').format(_scheduledDate!)
                              : 'Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter destination',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF6B7280),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.of(context).pop(value.trim());
                      }
                    },
                    onChanged: (val) => setState(() {}),
                  ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions horizontally scrollable
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _QuickActionChip(
                  icon: Icons.my_location_rounded,
                  label: 'Current Location',
                  onTap: () {},
                  isPrimary: true,
                ),
                const SizedBox(width: 12),
                _QuickActionChip(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _QuickActionChip(
                  icon: Icons.work_rounded,
                  label: 'Work',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _QuickActionChip(
                  icon: Icons.bookmark_rounded,
                  label: 'Saved',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              thickness: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Suggestions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return _LocationListTile(
                  title: suggestion['title']!,
                  subtitle: suggestion['subtitle']!,
                  icon: _getIconForType(suggestion['icon']!),
                  onTap: () {
                    // Navigate or select
                    Navigator.of(context).pop(suggestion['title']);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? colorScheme.primary.withValues(alpha: 0.3)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            width: 1,
          ),
          boxShadow: isPrimary
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? colorScheme.primary : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPrimary ? colorScheme.primary : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationListTile extends StatelessWidget {
  const _LocationListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
