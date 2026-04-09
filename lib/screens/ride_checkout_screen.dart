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
    final selected = await showModalBottomSheet<_PlaceOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlacePickerSheet(
        title: pickup
            ? context.tr(AppStrings.setPickupAddress)
            : context.tr(AppStrings.setDestinationAddress),
        current: pickup ? _pickup : _dropoff,
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
                                const SizedBox(height: 14),
                                _ServiceChipRow(
                                  selectedService: _selectedService,
                                  onSelected: (service) {
                                    setState(() {
                                      _selectedService = service;
                                    });
                                  },
                                ),
                                const SizedBox(height: 18),
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
                                const SizedBox(height: 14),
                                _RidePreferencesRow(
                                  scheduledDate: _scheduledDate,
                                  onTapNow: _pickScheduledDate,
                                  onClearScheduled: () => setState(() => _scheduledDate = null),
                                ),
                                const SizedBox(height: 18),
                                _PickupButton(
                                  hasPickup: _pickup != null,
                                  hasDropoff: _dropoff != null,
                                  isLoading: _isRequesting,
                                  onTap: () {
                                    if (_pickup == null) {
                                      _pickPlace(pickup: true);
                                      return;
                                    }
                                    if (_dropoff == null) {
                                      _pickPlace(pickup: false);
                                      return;
                                    }
                                    _requestDriver();
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 22,
          color: Color(0xFF1F2937),
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
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF18181B),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _AddressRow(
            markerColor: Color(0xFF18181B),
            markerLabel: 'A',
            label: pickupLabel,
            labelColor: theme.colorScheme.onSurface,
            showDivider: true,
            onTap: onPickupTap,
          ),
          const SizedBox(height: 12),
          _AddressRow(
            markerColor: Color(0xFFF97316),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaceholder = label == context.tr(AppStrings.dropOffAddress);
    if (!isPlaceholder) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF);
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
    final dividerColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  markerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: AppTypography.size,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.search_rounded,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF9CA3AF),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: dividerColor, indent: 36),
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
      height: 76,
      child: ListView(scrollDirection: Axis.horizontal, children: children),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const actionOrange = Color(0xFFF25E1C);
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);

    final selectedIndex = selectedService == _ServiceType.taxi
        ? 0
        : selectedService == _ServiceType.delivery
            ? 1
            : 2;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab(
              context,
              label: context.tr(AppStrings.taxi),
              isSelected: selectedIndex == 0,
              unselectedColor: textColor,
              actionOrange: actionOrange,
              onTap: () => onSelected(_ServiceType.taxi),
            ),
            _buildTab(
              context,
              label: context.tr(AppStrings.delivery),
              isSelected: selectedIndex == 1,
              unselectedColor: textColor,
              actionOrange: actionOrange,
              onTap: () => onSelected(_ServiceType.delivery),
            ),
            _buildTab(
              context,
              label: context.tr(AppStrings.cargo),
              isSelected: selectedIndex == 2,
              unselectedColor: textColor,
              actionOrange: actionOrange,
              onTap: () => onSelected(_ServiceType.cargo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color unselectedColor,
    required Color actionOrange,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? actionOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: actionOrange.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: theme.textTheme.labelLarge!.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : unselectedColor,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
              child: Text(label),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
        constraints: const BoxConstraints(minWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 50, child: Center(child: leading)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _ServiceImageThumbnail extends StatelessWidget {
  const _ServiceImageThumbnail({
    required this.assetPath,
    this.width = 68,
    this.height = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    this.imageScale = 1.0,
  });

  final String assetPath;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Transform.scale(
        scale: imageScale,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _TaxiImageThumbnail extends StatelessWidget {
  const _TaxiImageThumbnail({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return _ServiceImageThumbnail(
      assetPath: assetPath,
      width: 60,
      height: 40,
      imageScale: 1.2,
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
              _PreferenceButton(
                icon: Icons.access_time_rounded,
                label: label,
              ),
              if (scheduledDate != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClearScheduled,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ],
          ),
        ),
        Spacer(),
        _PreferenceButton(
          icon: Icons.payments_outlined,
          label: context.tr(AppStrings.cash),
          useChip: true,
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
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF25E1C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.52,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      autofocus: true,
                      cursorColor: colorScheme.onSurface,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr(AppStrings.searchForAPlace),
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF3F4F6),
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
                              : (isDark
                                    ? const Color(0xFF111827)
                                    : const Color(0xFFF8FAFC)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.place_outlined,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
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
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF6B7280),
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
        );
      },
    );
  }
}


