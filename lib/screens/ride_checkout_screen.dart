import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../app/localization.dart';
import '../app/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/schedule_ride_sheet.dart';
import 'confirm_order_screen.dart';

const _googleMapsApiKeyFallback = 'AIzaSyBzid8PyPK9S_eY3ymZLYo-iBNB01ShJYs';

class RideCheckoutScreen extends StatefulWidget {
  const RideCheckoutScreen({super.key});

  @override
  State<RideCheckoutScreen> createState() => _RideCheckoutScreenState();
}

class _RideCheckoutScreenState extends State<RideCheckoutScreen> {
  _PlaceOption? _pickup = _placeOptions.firstWhere(
    (place) => place.title == 'Lusaka',
  );
  _PlaceOption? _dropoff;
  _ServiceType _selectedService = _ServiceType.taxi;
  _TaxiTier _selectedTaxiTier = _TaxiTier.standard;
  _DeliveryTier _selectedDeliveryTier = _DeliveryTier.bicycleCourier;
  _CargoTier _selectedCargoTier = _CargoTier.minivan;
  bool _isRequesting = false;
  bool _isSearchingForDriver = false;
  String? _currentRideId;
  DateTime? _scheduledDate;

  bool _isPickingOnMap = false;
  bool _pickingForPickup = false;
  LatLng _mapPickCenter = const LatLng(-15.4067, 28.2871);

  Future<void> _pickScheduledDate() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ScheduleRideSheet(initialDate: _scheduledDate);
      },
    );

    if (result == 'now') {
      setState(() {
        _scheduledDate = null;
      });
    } else if (result is DateTime) {
      setState(() {
        _scheduledDate = result;
      });
    }
  }

  Future<void> _requestDriver() async {
    if (_isRequesting || _pickup == null || _dropoff == null) return;
    setState(() => _isRequesting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = await FirebaseFirestore.instance.collection('rides').add({
          'userId': user.uid,
          'scheduledDate': _scheduledDate?.toIso8601String(),
          'pickup': {
            'title': _pickup!.title,
            'subtitle': _pickup!.subtitle,
            'latitude': _pickup!.latLng.latitude,
            'longitude': _pickup!.latLng.longitude,
          },
          'dropoff': {
            'title': _dropoff!.title,
            'subtitle': _dropoff!.subtitle,
            'latitude': _dropoff!.latLng.latitude,
            'longitude': _dropoff!.latLng.longitude,
          },
          'serviceType': _selectedService.name,
          'taxiTier': _selectedTaxiTier.name,
          'deliveryTier': _selectedDeliveryTier.name,
          'cargoTier': _selectedCargoTier.name,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          setState(() {
            _currentRideId = docRef.id;
            _isSearchingForDriver = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to request a driver.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to request driver: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _cancelRequest() async {
    if (_currentRideId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(_currentRideId)
            .update({'status': 'cancelled'});
      } catch (e) {
        debugPrint('Failed to cancel ride: $e');
      }
    }
    if (mounted) {
      setState(() {
        _isSearchingForDriver = false;
        _currentRideId = null;
      });
    }
  }

  Future<void> _pickPlace({required bool pickup}) async {
    final selected = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (context) => _PlacePickerSheet(
          title: pickup
              ? context.tr(AppStrings.setPickupAddress)
              : context.tr(AppStrings.setDestinationAddress),
          current: pickup ? _pickup : _dropoff,
        ),
      ),
    );

    if (selected == null || !mounted) {
      return;
    }

    if (selected == '__map_pick__') {
      setState(() {
        _isPickingOnMap = true;
        _pickingForPickup = pickup;
      });
      return;
    }

    if (selected is _PlaceOption) {
      setState(() {
        if (pickup) {
          _pickup = selected;
        } else {
          _dropoff = selected;
        }
      });
    }
  }

  String _getSelectedPrice() {
    switch (_selectedService) {
      case _ServiceType.taxi:
        switch (_selectedTaxiTier) {
          case _TaxiTier.standard:
            return '26–32 ₺';
          case _TaxiTier.comfort:
            return '38–44 ₺';
          case _TaxiTier.vip:
            return '55–68 ₺';
        }
      case _ServiceType.delivery:
        switch (_selectedDeliveryTier) {
          case _DeliveryTier.bicycleCourier:
            return '15–20 ₺';
          case _DeliveryTier.motorcycleCourier:
            return '20–30 ₺';
        }
      case _ServiceType.cargo:
        switch (_selectedCargoTier) {
          case _CargoTier.minivan:
            return '40–55 ₺';
          case _CargoTier.panelVan:
            return '70–90 ₺';
          case _CargoTier.lightTruck:
            return '120–150 ₺';
        }
    }
  }

  List<Widget> _buildVehicleOptions() {
    switch (_selectedService) {
      case _ServiceType.taxi:
        return [
          _VehicleCard(
            selected: _selectedTaxiTier == _TaxiTier.standard,
            title: 'Standard',
            price: '26–32 ₺',
            assetPath: 'assets/images/IMG_0185.jpg',
            timeAway: '3 min away',
            driverName: 'BLF 2581',
            subtitle: 'Affordable • Toyota Corolla',
            iconData: Icons.local_taxi_rounded,
            iconColor: const Color(0xFFF97316),
            onTap: () => setState(() => _selectedTaxiTier = _TaxiTier.standard),
          ),
          const SizedBox(height: 12),
          _VehicleCard(
            selected: _selectedTaxiTier == _TaxiTier.comfort,
            title: 'Comfort',
            price: '38–44 ₺',
            assetPath: 'assets/images/car_plus.jpg',
            timeAway: '5 min away',
            subtitle: 'Comfortable • Mercedes-Benz',
            iconData: Icons.directions_car_rounded,
            iconColor: const Color(0xFF9CA3AF),
            onTap: () => setState(() => _selectedTaxiTier = _TaxiTier.comfort),
          ),
          const SizedBox(height: 12),
          _VehicleCard(
            selected: _selectedTaxiTier == _TaxiTier.vip,
            title: 'Premium',
            price: '55–68 ₺',
            assetPath: 'assets/images/car_business.jpg',
            timeAway: '4 min away',
            subtitle: 'Luxury • Black Sedan',
            iconData: Icons.directions_car_rounded,
            iconColor: const Color(0xFF9CA3AF),
            onTap: () => setState(() => _selectedTaxiTier = _TaxiTier.vip),
          ),
          const SizedBox(height: 24),
        ];
      case _ServiceType.delivery:
        return [
          _VehicleCard(
            selected: _selectedDeliveryTier == _DeliveryTier.bicycleCourier,
            title: 'Bicycle Courier',
            price: '15–20 ₺',
            assetPath: 'assets/images/bicycle.jpg',
            timeAway: '5 min away',
            subtitle: 'Eco-friendly • Small items',
            iconData: Icons.pedal_bike_rounded,
            iconColor: const Color(0xFFF97316),
            onTap: () => setState(() => _selectedDeliveryTier = _DeliveryTier.bicycleCourier),
          ),
          const SizedBox(height: 12),
          _VehicleCard(
            selected: _selectedDeliveryTier == _DeliveryTier.motorcycleCourier,
            title: 'Motorcycle Courier',
            price: '20–30 ₺',
            assetPath: 'assets/images/co-bike.jpg',
            timeAway: '3 min away',
            subtitle: 'Fast • Medium items',
            iconData: Icons.two_wheeler_rounded,
            iconColor: const Color(0xFF9CA3AF),
            onTap: () => setState(() => _selectedDeliveryTier = _DeliveryTier.motorcycleCourier),
          ),
          const SizedBox(height: 24),
        ];
      case _ServiceType.cargo:
        return [
          _VehicleCard(
            selected: _selectedCargoTier == _CargoTier.minivan,
            title: 'Minivan',
            price: '40–55 ₺',
            assetPath: 'assets/images/small_truck.jpg',
            timeAway: '10 min away',
            subtitle: 'Small moves • Few boxes',
            iconData: Icons.airport_shuttle_rounded,
            iconColor: const Color(0xFFF97316),
            onTap: () => setState(() => _selectedCargoTier = _CargoTier.minivan),
          ),
          const SizedBox(height: 12),
          _VehicleCard(
            selected: _selectedCargoTier == _CargoTier.panelVan,
            title: 'Panel Van',
            price: '70–90 ₺',
            assetPath: 'assets/images/mid-truck.jpg',
            timeAway: '15 min away',
            subtitle: 'Medium moves • Furniture',
            iconData: Icons.local_shipping_rounded,
            iconColor: const Color(0xFF9CA3AF),
            onTap: () => setState(() => _selectedCargoTier = _CargoTier.panelVan),
          ),
          const SizedBox(height: 12),
          _VehicleCard(
            selected: _selectedCargoTier == _CargoTier.lightTruck,
            title: 'Light Truck',
            price: '120–150 ₺',
            assetPath: 'assets/images/large_truck.jpg',
            timeAway: '25 min away',
            subtitle: 'Large moves • Full house',
            iconData: Icons.fire_truck_rounded,
            iconColor: const Color(0xFF9CA3AF),
            onTap: () => setState(() => _selectedCargoTier = _CargoTier.lightTruck),
          ),
          const SizedBox(height: 24),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _RideCheckoutMap(
              isPickingMode: _isPickingOnMap,
              onCameraMove: (position) {
                if (_isPickingOnMap) {
                  _mapPickCenter = position.target;
                }
              },
            ),
          ),
          
          if (!_isSearchingForDriver) ...[
            // Map Zoom Controls
            if (!_isPickingOnMap)
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.35,
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.add, size: 24, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    Container(width: 24, height: 1, color: const Color(0xFFE5E7EB)),
                    InkWell(
                      onTap: () {},
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.remove, size: 24, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Content (Back button)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        if (_isPickingOnMap) {
                          setState(() {
                            _isPickingOnMap = false;
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            if (_isPickingOnMap)
              // Confirm Location Button for Map Picking Mode
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final newPlace = _PlaceOption(
                          title: 'Selected Location',
                          subtitle: '${_mapPickCenter.latitude.toStringAsFixed(4)}, ${_mapPickCenter.longitude.toStringAsFixed(4)}',
                          latLng: _mapPickCenter,
                        );
                        if (_pickingForPickup) {
                          _pickup = newPlace;
                        } else {
                          _dropoff = newPlace;
                        }
                        _isPickingOnMap = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Bottom Sheet Content
              Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _AddressInputs(
                          pickupLabel: _pickup?.title ?? context.tr(AppStrings.setPickupAddress),
                          dropoffLabel: _dropoff?.title ?? context.tr(AppStrings.setDestinationAddress),
                          onPickupTap: () => _pickPlace(pickup: true),
                          onDropoffTap: () => _pickPlace(pickup: false),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Service Type Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: _ServiceType.values.map((type) {
                              final isSelected = _selectedService == type;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedService = type),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      type.name[0].toUpperCase() + type.name.substring(1),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 320,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: _buildVehicleOptions(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _PickupButton(
                          hasPickup: _pickup != null,
                          hasDropoff: _dropoff != null,
                          isLoading: _isRequesting,
                          onTap: () async {
                            if (_pickup == null) {
                              _pickPlace(pickup: true);
                              return;
                            }
                            if (_dropoff == null) {
                              _pickPlace(pickup: false);
                              return;
                            }
                            final confirmed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => ConfirmOrderScreen(
                                  targetLocation: _pickup!.latLng,
                                  cityName: _pickup!.title,
                                  price: _getSelectedPrice(),
                                ),
                              ),
                            );
                            if (confirmed == true && mounted) {
                              _requestDriver();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          if (_isSearchingForDriver)
            Positioned.fill(
              child: Container(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _SearchingDriverView(onCancel: _cancelRequest),
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

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFF97316) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ServiceType { taxi, delivery, cargo }

enum _TaxiTier { standard, comfort, vip }

enum _DeliveryTier { bicycleCourier, motorcycleCourier }

enum _CargoTier { minivan, panelVan, lightTruck }

class _RideCheckoutMap extends StatelessWidget {
  const _RideCheckoutMap({this.onCameraMove, this.isPickingMode = false});
  final void Function(CameraPosition)? onCameraMove;
  final bool isPickingMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _RideMapView(onCameraMove: onCameraMove)),
        if (!isPickingMode) const Positioned.fill(child: IgnorePointer(child: _MapGridOverlay())),
        if (!isPickingMode) const Positioned.fill(child: IgnorePointer(child: _EtaMapPointer())),
        if (isPickingMode) const Positioned.fill(child: IgnorePointer(child: _CenterPickPointer())),
      ],
    );
  }
}

class _CenterPickPointer extends StatelessWidget {
  const _CenterPickPointer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: const Icon(
          Icons.location_on,
          size: 40,
          color: Color(0xFFF97316),
        ),
      ),
    );
  }
}

class _RideMapView extends StatefulWidget {
  const _RideMapView({this.onCameraMove});
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<_RideMapView> createState() => _RideMapViewState();
}

class _RideMapViewState extends State<_RideMapView> {
  GoogleMapController? _controller;
  LatLng _initialTarget = const LatLng(-15.4067, 28.2871);

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
      initialCameraPosition: CameraPosition(target: _initialTarget, zoom: 14.8),
      onCameraMove: widget.onCameraMove,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      padding: const EdgeInsets.only(bottom: 480, top: 80),
    );
  }
}

class _RideStaticMap extends StatelessWidget {
  const _RideStaticMap({required this.center});

  final LatLng center;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    final resolvedApiKey = apiKey.isEmpty ? _googleMapsApiKeyFallback : apiKey;
    if (resolvedApiKey.isEmpty) {
      return ColoredBox(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE5E7EB),
      );
    }

    final url =
        'https://maps.googleapis.com/maps/api/staticmap?center=${center.latitude},${center.longitude}'
        '&zoom=14&size=900x1400&maptype=roadmap&style=feature:poi|visibility:off'
        '&style=feature:transit.station|visibility:on'
        '&key=$resolvedApiKey';
    return Image.network(url, fit: BoxFit.cover);
  }
}

class _MapGridOverlay extends StatelessWidget {
  const _MapGridOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? Colors.black : Colors.white).withValues(alpha: 0.08),
            (isDark ? Colors.black : Colors.white).withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}

class _CloseMapButton extends StatelessWidget {
  const _CloseMapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          size: 24,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _EtaMapPointer extends StatelessWidget {
  const _EtaMapPointer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '6',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'min',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _AddressInputs extends StatelessWidget {
  const _AddressInputs({
    required this.pickupLabel,
    required this.dropoffLabel,
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  final String pickupLabel;
  final String dropoffLabel;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onPickupTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pickupLabel,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Text(
                            '6 min away',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280), size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    height: 1,
                    color: const Color(0xFFF3F4F6),
                  ),
                ),
                GestureDetector(
                  onTap: onDropoffTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dropoffLabel,
                        style: TextStyle(
                          color: dropoffLabel == context.tr(AppStrings.dropOffAddress)
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF1A1A1A),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.assetPath,
    required this.timeAway,
    required this.subtitle,
    required this.iconData,
    required this.iconColor,
    this.driverName,
    this.onTap,
  });

  final bool selected;
  final String title;
  final String price;
  final String assetPath;
  final String timeAway;
  final String subtitle;
  final IconData iconData;
  final Color iconColor;
  final String? driverName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFF97316) : Colors.transparent,
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconData, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  width: 90,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (driverName != null) ...[
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundImage: AssetImage('assets/images/PHOTO-2026-03-27-20-08-38.jpg'),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              driverName!,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          if (driverName != null) ...[
                            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  timeAway,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceImageThumbnail extends StatelessWidget {
  const _ServiceImageThumbnail({
    required this.assetPath,
    this.width = 72,
    this.height = 56,
    this.padding = EdgeInsets.zero,
    this.imageScale = 1.0,
  });

  final String assetPath;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _TaxiImageThumbnail extends StatelessWidget {
  const _TaxiImageThumbnail({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        width: 72,
        height: 56,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ServiceIconThumbnail extends StatelessWidget {
  const _ServiceIconThumbnail({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 68,
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 34, color: color),
    );
  }
}

class _RidePreferencesRow extends StatelessWidget {
  const _RidePreferencesRow({
    this.scheduledDate,
    required this.onTapNow,
    required this.onClearScheduled,
  });

  final DateTime? scheduledDate;
  final VoidCallback onTapNow;
  final VoidCallback onClearScheduled;

  @override
  Widget build(BuildContext context) {
    String label = context.tr(AppStrings.now);
    if (scheduledDate != null) {
      final now = DateTime.now();
      if (scheduledDate!.year == now.year &&
          scheduledDate!.month == now.month &&
          scheduledDate!.day == now.day) {
        label = DateFormat.jm().format(scheduledDate!);
      } else {
        label = DateFormat('MMM d, h:mm a').format(scheduledDate!);
      }
    }
    return Row(
      children: [
        GestureDetector(
          onTap: onTapNow,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 22,
                color: const Color(0xFF1A1A1A),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (scheduledDate != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClearScheduled,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr(AppStrings.cash),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreferenceButton extends StatelessWidget {
  const _PreferenceButton({
    required this.icon,
    required this.label,
    this.useChip = false,
    this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool useChip;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (useChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payments, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          )
        else
          Icon(icon, size: 22, color: const Color(0xFF111827)),
        if (!useChip) const SizedBox(width: 8) else const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    if (onClear != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

class _PickupButton extends StatelessWidget {
  const _PickupButton({
    required this.onTap,
    required this.hasPickup,
    required this.hasDropoff,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool hasPickup;
  final bool hasDropoff;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Confirm pick-up point',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, size: 24),
                ],
              ),
      ),
    );
  }
}

class _SearchingDriverView extends StatelessWidget {
  const _SearchingDriverView({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF25E1C)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Finding you a driver...',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This usually takes about a minute',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PlaceOption {

  const _PlaceOption({
    required this.title,
    required this.subtitle,
    required this.latLng,
  });

  final String title;
  final String subtitle;
  final LatLng latLng;
}

const List<_PlaceOption> _placeOptions = [
  _PlaceOption(
    title: 'Lusaka',
    subtitle: 'Lusaka Province, Zambia',
    latLng: LatLng(-15.3875, 28.3228),
  ),
  _PlaceOption(
    title: 'Levy Junction Shopping Mall',
    subtitle: 'Church Road, Lusaka',
    latLng: LatLng(-15.4162, 28.2873),
  ),
  _PlaceOption(
    title: 'East Park Mall',
    subtitle: 'Great East Road, Lusaka',
    latLng: LatLng(-15.3865, 28.3256),
  ),
  _PlaceOption(
    title: 'Manda Hill Shopping Centre',
    subtitle: 'Great East Road, Lusaka',
    latLng: LatLng(-15.4017, 28.3097),
  ),
  _PlaceOption(
    title: 'Cavendish University Zambia',
    subtitle: 'Lusaka, Zambia',
    latLng: LatLng(-15.4089, 28.2729),
  ),
  _PlaceOption(
    title: 'UNZA',
    subtitle: 'University of Zambia, Lusaka',
    latLng: LatLng(-15.3858, 28.3186),
  ),
  _PlaceOption(
    title: 'Arcades Shopping Mall',
    subtitle: 'Lusaka, Zambia',
    latLng: LatLng(-15.3888, 28.3191),
  ),
  _PlaceOption(
    title: 'Ibex Hill',
    subtitle: 'Ibex Hill, Lusaka',
    latLng: LatLng(-15.4302, 28.3047),
  ),
  _PlaceOption(
    title: 'Woodlands',
    subtitle: 'Woodlands, Lusaka',
    latLng: LatLng(-15.4415, 28.3028),
  ),
  _PlaceOption(
    title: 'Northmead',
    subtitle: 'Northmead, Lusaka',
    latLng: LatLng(-15.4095, 28.2909),
  ),
];

class _PlacePickerSheet extends StatefulWidget {
  const _PlacePickerSheet({required this.title, this.current});

  final String title;
  final _PlaceOption? current;

  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.current?.title ?? '',
    );
    _query = _searchController.text;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _placeOptions.where((place) {
      if (_query.trim().isEmpty) {
        return true;
      }
      final q = _query.toLowerCase();
      return place.title.toLowerCase().contains(q) ||
          place.subtitle.toLowerCase().contains(q);
    }).toList();

    String formattedTitle = widget.title;
    if (formattedTitle.toLowerCase().startsWith('set ')) {
      formattedTitle = formattedTitle.substring(4);
    } else if (formattedTitle.toLowerCase().startsWith('vendos ')) {
      formattedTitle = formattedTitle.substring(7);
    }
    if (formattedTitle.isNotEmpty) {
      formattedTitle = formattedTitle[0].toUpperCase() + formattedTitle.substring(1);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Top close button
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // The text field with orange label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedTitle,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    autofocus: true,
                    cursorColor: colorScheme.primary,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary, width: 1),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      ),
                      suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF475569) : const Color(0xFF9CA3AF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: theme.scaffoldBackgroundColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Set point on map option
            InkWell(
              onTap: () {
                Navigator.of(context).pop('__map_pick__');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Set point on map',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // The list of filtered places
            if (filtered.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                  ),
                  itemBuilder: (context, index) {
                    final place = filtered[index];
                    final selected = widget.current?.title == place.title;
                    return ListTile(
                      onTap: () => Navigator.of(context).pop(place),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : (isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.place_outlined,
                          color: selected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        place.title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        place.subtitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_rounded,
                              color: colorScheme.primary,
                            )
                          : const Icon(Icons.chevron_right_rounded),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


