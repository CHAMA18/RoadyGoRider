import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';

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

  Future<void> _pickPlace({required bool pickup}) async {
    final selected = await showModalBottomSheet<_PlaceOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlacePickerSheet(
        title: pickup ? 'Set pick-up address' : 'Set destination address',
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
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.26 : 0.08,
                          ),
                          blurRadius: 25,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _DragHandle(),
                          const SizedBox(height: 12),
                          _AddressInputs(
                            pickupLabel: _pickup?.title ?? 'Set pick-up point',
                            dropoffLabel: _dropoff?.title ?? 'Drop-off address',
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
                          const _RidePreferencesRow(),
                          const SizedBox(height: 18),
                          _PickupButton(
                            hasPickup: _pickup != null,
                            hasDropoff: _dropoff != null,
                            onTap: () {
                              if (_pickup == null) {
                                _pickPlace(pickup: true);
                                return;
                              }
                              if (_dropoff == null) {
                                _pickPlace(pickup: false);
                              }
                            },
                          ),
                          const SizedBox(height: 22),
                          const HomeIndicator(),
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

class _RideMapView extends StatelessWidget {
  const _RideMapView();

  @override
  Widget build(BuildContext context) {
    final center = const LatLng(-15.4067, 28.2871);
    if (kIsWeb) {
      return _RideStaticMap(center: center);
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 14.8),
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
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
        width: 52,
        height: 52,
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
          size: 26,
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'MIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
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
                color: const Color(0xFF18181B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
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

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
    final isPlaceholder = label == 'Drop-off address';
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
      borderRadius: BorderRadius.circular(14),
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
                color: labelColor.withValues(alpha: 0.85),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: dividerColor),
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
              title: 'Standard Taxi',
              subtitle: 'From 28 ZMW',
              leading: Image.asset(
                'assets/images/car_icon_final.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.standard),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedTaxiTier == _TaxiTier.comfort,
              title: 'Comfort Taxi',
              subtitle: 'From 40 ZMW',
              leading: const Icon(
                Icons.airline_seat_recline_extra_rounded,
                size: 34,
                color: Color(0xFF2563EB),
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.comfort),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedTaxiTier == _TaxiTier.vip,
              title: 'VIP Taxi',
              subtitle: 'From 65 ZMW',
              leading: const Icon(
                Icons.workspace_premium_rounded,
                size: 34,
                color: Color(0xFFCA8A04),
              ),
              onTap: () => onTaxiTierSelected(_TaxiTier.vip),
            ),
          ]
        : selectedService == _ServiceType.delivery
        ? [
            _VehicleCard(
              selected: selectedDeliveryTier == _DeliveryTier.bicycleCourier,
              title: 'Bicycle Courier',
              subtitle: 'From 12 ZMW',
              leading: const Icon(
                Icons.pedal_bike_rounded,
                size: 34,
                color: Color(0xFF16A34A),
              ),
              onTap: () => onDeliveryTierSelected(_DeliveryTier.bicycleCourier),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedDeliveryTier == _DeliveryTier.motorcycleCourier,
              title: 'Motorcycle Courier',
              subtitle: 'From 20 ZMW',
              leading: const Icon(
                Icons.two_wheeler_rounded,
                size: 34,
                color: Color(0xFFFB923C),
              ),
              onTap: () =>
                  onDeliveryTierSelected(_DeliveryTier.motorcycleCourier),
            ),
          ]
        : selectedService == _ServiceType.cargo
        ? [
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.minivan,
              title: 'Minivan',
              subtitle: 'From 45 ZMW',
              leading: const Icon(
                Icons.airport_shuttle_rounded,
                size: 34,
                color: Color(0xFF2563EB),
              ),
              onTap: () => onCargoTierSelected(_CargoTier.minivan),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.panelVan,
              title: 'Panel Van',
              subtitle: 'From 60 ZMW',
              leading: const Icon(
                Icons.local_shipping_outlined,
                size: 34,
                color: Color(0xFFF97316),
              ),
              onTap: () => onCargoTierSelected(_CargoTier.panelVan),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: selectedCargoTier == _CargoTier.lightTruck,
              title: 'Light Truck',
              subtitle: 'From 85 ZMW',
              leading: Image.asset(
                'assets/images/truck.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
              onTap: () => onCargoTierSelected(_CargoTier.lightTruck),
            ),
          ]
        : [
            _VehicleCard(
              selected: false,
              title: 'Delivery',
              subtitle: 'From 20 ZMW',
              leading: const Icon(
                Icons.two_wheeler_rounded,
                size: 34,
                color: Color(0xFFFB923C),
              ),
              onTap: () => onSelected(_ServiceType.delivery),
            ),
            const SizedBox(width: 14),
            _VehicleCard(
              selected: false,
              title: 'Cargo',
              subtitle: 'From 45 ZMW',
              leading: Image.asset(
                'assets/images/truck.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
              onTap: () => onSelected(_ServiceType.cargo),
            ),
          ];

    return SizedBox(
      height: 94,
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
    final colorScheme = theme.colorScheme;

    Widget chip(
      String label, {
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1F2937) : colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip(
              'Taxi',
              selected: selectedService == _ServiceType.taxi,
              onTap: () => onSelected(_ServiceType.taxi),
            ),
            const SizedBox(width: 10),
            chip(
              'Delivery',
              selected: selectedService == _ServiceType.delivery,
              onTap: () => onSelected(_ServiceType.delivery),
            ),
            const SizedBox(width: 10),
            chip(
              'Cargo',
              selected: selectedService == _ServiceType.cargo,
              onTap: () => onSelected(_ServiceType.cargo),
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
        width: 252,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFF97316) : Colors.transparent,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            SizedBox(width: 64, child: Center(child: leading)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

class _RidePreferencesRow extends StatelessWidget {
  const _RidePreferencesRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _PreferenceButton(icon: Icons.access_time_rounded, label: 'Now'),
        Spacer(),
        _PreferenceButton(
          icon: Icons.payments_outlined,
          label: 'Cash',
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
  });

  final IconData icon;
  final String label;
  final bool useChip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (useChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '💵 •',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          )
        else
          Icon(icon, size: 22, color: Color(0xFF111827)),
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
  }
}

class _PickupButton extends StatelessWidget {
  const _PickupButton({
    required this.onTap,
    required this.hasPickup,
    required this.hasDropoff,
  });

  final VoidCallback onTap;
  final bool hasPickup;
  final bool hasDropoff;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF25E1C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          hasPickup && hasDropoff ? 'Continue' : 'Set pick-up point',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        hintText: 'Search for a place',
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
