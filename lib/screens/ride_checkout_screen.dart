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
    final selected = await Navigator.of(context).push<_PlaceOption>(
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

    setState(() {
      if (pickup) {
        _pickup = selected;
      } else {
        _dropoff = selected;
      }
    });
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
          const Positioned.fill(child: _RideCheckoutMap()),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 20,
                  child: _CloseMapButton(
                    onTap: () => Navigator.of(context).maybePop(),
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
                        colors: [
                          colorScheme.surface.withValues(alpha: 0.0),
                          colorScheme.surface,
                          colorScheme.surface,
                        ],
                        stops: const [0.0, 0.15, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 40, 16, MediaQuery.paddingOf(context).bottom > 0 ? MediaQuery.paddingOf(context).bottom : 16),
                      child: _isSearchingForDriver
                          ? _SearchingDriverView(onCancel: _cancelRequest)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AddressInputs(
                                  pickupLabel:
                                      _pickup?.title ??
                                      context.tr(AppStrings.setPickupPoint),
                                  dropoffLabel:
                                      _dropoff?.title ??
                                      context.tr(AppStrings.dropOffAddress),
                                  onPickupTap: () => _pickPlace(pickup: true),
                                  onDropoffTap: () => _pickPlace(pickup: false),
                                ),
                                const SizedBox(height: 16),
                                _ServiceChipRow(
                                  selectedService: _selectedService,
                                  onSelected: (service) {
                                    setState(() {
                                      _selectedService = service;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _VehicleSlider(
                                  selectedService: _selectedService,
                                  selectedTaxiTier: _selectedTaxiTier,
                                  selectedDeliveryTier: _selectedDeliveryTier,
                                  selectedCargoTier: _selectedCargoTier,
                                  onSelected: (service) {
                                    setState(() {
                                      _selectedService = service;
                                    });
                                  },
                                  onTaxiTierSelected: (tier) {
                                    setState(() {
                                      _selectedService = _ServiceType.taxi;
                                      _selectedTaxiTier = tier;
                                    });
                                  },
                                  onDeliveryTierSelected: (tier) {
                                    setState(() {
                                      _selectedService = _ServiceType.delivery;
                                      _selectedDeliveryTier = tier;
                                    });
                                  },
                                  onCargoTierSelected: (tier) {
                                    setState(() {
                                      _selectedService = _ServiceType.cargo;
                                      _selectedCargoTier = tier;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                _RidePreferencesRow(
                                  scheduledDate: _scheduledDate,
                                  onTapNow: _pickScheduledDate,
                                  onClearScheduled: () => setState(() => _scheduledDate = null),
                                ),
                                const SizedBox(height: 20),
                                _PickupButton(
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
                                          price: '140 ZMW',
                                        ),
                                      ),
                                    );
                                    if (confirmed == true && mounted) {
                                      _requestDriver();
                                    }
                                  },
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

enum _ServiceType { taxi, delivery, cargo }

enum _TaxiTier { standard, comfort, vip }

enum _DeliveryTier { bicycleCourier, motorcycleCourier }

enum _CargoTier { minivan, panelVan, lightTruck }

class _RideCheckoutMap extends StatelessWidget {
  const _RideCheckoutMap();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned.fill(child: _RideMapView()),
        Positioned.fill(child: IgnorePointer(child: _MapGridOverlay())),
        Positioned.fill(child: IgnorePointer(child: _EtaMapPointer())),
      ],
    );
  }
}

class _RideMapView extends StatefulWidget {
  const _RideMapView();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _AddressRow(
            markerColor: const Color(0xFF1A1A1A),
            markerLabel: 'A',
            label: pickupLabel,
            labelColor: const Color(0xFF1A1A1A),
            showDivider: true,
            onTap: onPickupTap,
          ),
          const SizedBox(height: 14),
          _AddressRow(
            markerColor: const Color(0xFFF97316),
            markerLabel: 'B',
            label: dropoffLabel,
            labelColor: _dropoffColor(context, dropoffLabel),
            showDivider: false,
            onTap: onDropoffTap,
          ),
        ],
      ),
    );
  }

  Color _dropoffColor(BuildContext context, String label) {
    final isPlaceholder = label == context.tr(AppStrings.dropOffAddress);
    if (!isPlaceholder) {
      return const Color(0xFF1A1A1A);
    }
    return const Color(0xFF9CA3AF);
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.markerColor,
    required this.markerLabel,
    required this.label,
    required this.labelColor,
    required this.showDivider,
    required this.onTap,
  });

  final Color markerColor;
  final String markerLabel;
  final String label;
  final Color labelColor;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  markerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 42),
          ],
        ],
      ),
    );
  }
}

class _VehicleSlider extends StatelessWidget {
  const _VehicleSlider({
    required this.selectedService,
    required this.selectedTaxiTier,
    required this.selectedDeliveryTier,
    required this.selectedCargoTier,
    required this.onSelected,
    required this.onTaxiTierSelected,
    required this.onDeliveryTierSelected,
    required this.onCargoTierSelected,
  });

  final _ServiceType selectedService;
  final _TaxiTier selectedTaxiTier;
  final _DeliveryTier selectedDeliveryTier;
  final _CargoTier selectedCargoTier;
  final ValueChanged<_ServiceType> onSelected;
  final ValueChanged<_TaxiTier> onTaxiTierSelected;
  final ValueChanged<_DeliveryTier> onDeliveryTierSelected;
  final ValueChanged<_CargoTier> onCargoTierSelected;

  @override
  Widget build(BuildContext context) {
    final children = selectedService == _ServiceType.taxi
        ? [
            _VehicleCard(
              selected: selectedTaxiTier == _TaxiTier.standard,
              title: context.tr(AppStrings.standardTaxi),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '28 ₺'},
              ),
              leading: const _TaxiImageThumbnail(
                assetPath: 'assets/images/IMG_0185.jpg',
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.standard),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedTaxiTier == _TaxiTier.comfort,
              title: context.tr(AppStrings.comfortTaxi),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '40 ₺'},
              ),
              leading: const _TaxiImageThumbnail(
                assetPath: 'assets/images/car_plus.jpg',
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.comfort),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedTaxiTier == _TaxiTier.vip,
              title: context.tr(AppStrings.vipTaxi),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '65 ₺'},
              ),
              leading: const _TaxiImageThumbnail(
                assetPath: 'assets/images/car_business.jpg',
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.vip),
            ),
          ]
        : selectedService == _ServiceType.delivery
        ? [
            _VehicleCard(
              selected: selectedDeliveryTier == _DeliveryTier.bicycleCourier,
              title: context.tr(AppStrings.bicycleCourier),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '12 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/bicycle.jpg',
                imageScale: 1.8,
              ),
              onTap: () => onDeliveryTierSelected(_DeliveryTier.bicycleCourier),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedDeliveryTier == _DeliveryTier.motorcycleCourier,
              title: context.tr(AppStrings.motorcycleCourier),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '20 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/co-bike.jpg',
                width: 86,
                height: 60,
              ),
              onTap: () =>
                  onDeliveryTierSelected(_DeliveryTier.motorcycleCourier),
            ),
          ]
        : selectedService == _ServiceType.cargo
        ? [
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.minivan,
              title: context.tr(AppStrings.minivan),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '45 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/small_truck.jpg',
                width: 76,
                height: 52,
                imageScale: 1.0,
                padding: EdgeInsets.zero,
              ),
              onTap: () => onCargoTierSelected(_CargoTier.minivan),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.panelVan,
              title: context.tr(AppStrings.panelVan),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '60 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/mid-truck.jpg',
                width: 76,
                height: 52,
                imageScale: 1.0,
                padding: EdgeInsets.zero,
              ),
              onTap: () => onCargoTierSelected(_CargoTier.panelVan),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.lightTruck,
              title: context.tr(AppStrings.lightTruck),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '85 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/large_truck.jpg',
                width: 76,
                height: 52,
                imageScale: 1.0,
                padding: EdgeInsets.zero,
              ),
              onTap: () => onCargoTierSelected(_CargoTier.lightTruck),
            ),
          ]
        : [
            _VehicleCard(
              selected: false,
              title: context.tr(AppStrings.delivery),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '20 ₺'},
              ),
              leading: const _ServiceIconThumbnail(
                icon: Icons.two_wheeler_rounded,
                color: Color(0xFFFB923C),
              ),
              onTap: () => onSelected(_ServiceType.delivery),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: false,
              title: context.tr(AppStrings.cargo),
              subtitle: context.tr(
                AppStrings.fromPrice,
                params: {'price': '45 ₺'},
              ),
              leading: const _ServiceImageThumbnail(
                assetPath: 'assets/images/truck.png',
              ),
              onTap: () => onSelected(_ServiceType.cargo),
            ),
          ];

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: children,
      ),
    );
  }
}

class _ServiceChipRow extends StatelessWidget {
  const _ServiceChipRow({
    required this.selectedService,
    required this.onSelected,
  });

  final _ServiceType selectedService;
  final ValueChanged<_ServiceType> onSelected;

  static const _tabs = [_ServiceType.taxi, _ServiceType.delivery, _ServiceType.cargo];

  int get _selectedIndex => _tabs.indexOf(selectedService);

  IconData _iconForService(_ServiceType type) {
    switch (type) {
      case _ServiceType.taxi:
        return Icons.local_taxi_rounded;
      case _ServiceType.delivery:
        return Icons.delivery_dining_rounded;
      case _ServiceType.cargo:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryOrange = Color(0xFFF97316);
    final bgColor = isDark ? const Color(0xFF1A1D23) : const Color(0xFFF1F5F9);
    final inactiveText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
        child: Container(
          height: 36,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = (constraints.maxWidth - 4) / 3;
              return Stack(
                children: [
                  // Animated sliding indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: 2 + (_selectedIndex * tabWidth),
                    top: 0,
                    bottom: 0,
                    width: tabWidth - 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Tab buttons
                  Row(
                    children: List.generate(3, (index) {
                      final type = _tabs[index];
                      final isSelected = index == _selectedIndex;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onSelected(type),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _iconForService(type),
                                  size: 14,
                                  color: isSelected ? Colors.white : inactiveText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _labelForService(context, type),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : inactiveText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _labelForService(BuildContext context, _ServiceType type) {
    switch (type) {
      case _ServiceType.taxi:
        return context.tr(AppStrings.taxi);
      case _ServiceType.delivery:
        return context.tr(AppStrings.delivery);
      case _ServiceType.cargo:
        return context.tr(AppStrings.cargo);
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    this.leading,
    this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 86,
        padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFF97316) : const Color(0xFFE8E8E8),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 56,
              child: leading,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
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
            borderRadius: BorderRadius.circular(12),
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
            : Text(
                hasPickup && hasDropoff
                    ? context.tr(AppStrings.continueLabel)
                    : context.tr(AppStrings.setPickupPoint),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
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
                // Action for setting point on map
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


