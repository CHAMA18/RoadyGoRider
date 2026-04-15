import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../app/theme.dart';

class ConfirmOrderScreen extends StatefulWidget {
  const ConfirmOrderScreen({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.cityName,
    required this.price,
  });

  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String cityName;
  final String price;

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  bool _isSearching = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (_isSearching) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
    });
    
    // Play a sound notification when starting to look for a ride
    FlutterRingtonePlayer().playNotification();
    
    _animationController.repeat();
    
    // Zoom out to show 5km radius around pickup
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.pickupLocation,
          zoom: 12.0, 
        ),
      ),
    );

    // After animation, return to checkout screen
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    
    // Align map to show both pickup and dropoff
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(widget.pickupLocation.latitude, widget.dropoffLocation.latitude),
          min(widget.pickupLocation.longitude, widget.dropoffLocation.longitude),
        ),
        northeast: LatLng(
          max(widget.pickupLocation.latitude, widget.dropoffLocation.latitude),
          max(widget.pickupLocation.longitude, widget.dropoffLocation.longitude),
        ),
      );
      
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80)); // 80 padding
    });
  }

  Set<Circle> get _circles {
    if (!_isSearching) return {};
    
    double value1 = _animationController.value;
    double value2 = (value1 + 0.5) % 1.0;

    return {
      Circle(
        circleId: const CircleId('radar_1'),
        center: widget.pickupLocation,
        radius: 5000 * value1,
        fillColor: const Color(0xFFF97316).withValues(alpha: 0.2 * (1 - value1)),
        strokeColor: const Color(0xFFF97316).withValues(alpha: 0.5 * (1 - value1)),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('radar_2'),
        center: widget.pickupLocation,
        radius: 5000 * value2,
        fillColor: const Color(0xFFF97316).withValues(alpha: 0.2 * (1 - value2)),
        strokeColor: const Color(0xFFF97316).withValues(alpha: 0.5 * (1 - value2)),
        strokeWidth: 2,
      ),
    };
  }

  Set<Marker> get _markers {
    if (_isSearching) return {};
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: widget.dropoffLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  Set<Polyline> get _polylines {
    if (_isSearching) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFFF97316),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        points: [
          widget.pickupLocation,
          widget.dropoffLocation,
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (widget.pickupLocation.latitude + widget.dropoffLocation.latitude) / 2,
                  (widget.pickupLocation.longitude + widget.dropoffLocation.longitude) / 2,
                ),
                zoom: 14.0,
              ),
              circles: _circles,
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              buildingsEnabled: false,
              indoorViewEnabled: false,
              padding: const EdgeInsets.only(top: 150, bottom: 120),
            ),
          ),

          // City Name floating near top
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Text(
                  widget.cityName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                    shadows: [
                      Shadow(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // UI Elements Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Left Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),

                // Bottom Left Chat Button
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement chat logic
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // Confirm Order Button or Searching Indicator
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Looking for drivers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Searching within 5 km radius...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startSearching,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316), // Orange
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Confirm order',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.price,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
