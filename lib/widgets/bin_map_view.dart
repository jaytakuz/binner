import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/bin.dart';
import '../themes/app_theme.dart';
import '../pages/bin_details_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//   Replace with your real key
//   Android → android/app/src/main/AndroidManifest.xml  <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
//   iOS     → ios/Runner/AppDelegate.swift               GMSServices.provideAPIKey("YOUR_KEY")
String get _kGoogleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

class BinMapView extends StatefulWidget {
  final List<Bin> bins;
  const BinMapView({super.key, required this.bins});

  @override
  State<BinMapView> createState() => _BinMapViewState();
}

class _BinMapViewState extends State<BinMapView> {
  GoogleMapController? _mapController;
  final Location _locationService = Location();

  LocationData? _userLocation;
  bool _locationGranted = false;
  bool _isLoadingRoute = false;
  Bin? _selectedBin;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(18.8050, 98.9535), // CMU area
    zoom: 15.5,
  );

  @override
  void initState() {
    super.initState();
    _buildBinMarkers();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Location ────────────────────────────────────────────────────────────────
  Future<void> _initLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }
    PermissionStatus perm = await _locationService.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await _locationService.requestPermission();
      if (perm != PermissionStatus.granted) return;
    }
    setState(() => _locationGranted = true);
    final loc = await _locationService.getLocation();
    _onLocationUpdate(loc);
    _locationService.onLocationChanged.listen(_onLocationUpdate);
  }

  void _onLocationUpdate(LocationData loc) {
    if (!mounted) return;
    setState(() => _userLocation = loc);
  }

  void _goToMyLocation() {
    if (_userLocation == null) {
      _initLocation();
      return;
    }
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
        16,
      ),
    );
  }

  // ── Markers ─────────────────────────────────────────────────────────────────
  void _buildBinMarkers() {
    _markers.clear();
    for (final bin in widget.bins) {
      _markers.add(
        Marker(
          markerId: MarkerId(bin.id),
          position: LatLng(bin.latitude, bin.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(_binHue(bin.binType)),
          infoWindow: InfoWindow(
            title: bin.name,
            snippet: AppTheme.getBinTypeName(bin.binType),
          ),
          onTap: () => _selectBin(bin),
        ),
      );
    }
    if (mounted) setState(() {});
  }

  double _binHue(String type) {
    switch (type) {
      case 'green':
        return BitmapDescriptor.hueGreen;
      case 'yellow':
        return BitmapDescriptor.hueYellow;
      case 'red':
        return BitmapDescriptor.hueRed;
      case 'orange':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  // ── Select bin → focus + route ───────────────────────────────────────────────
  Future<void> _selectBin(Bin bin) async {
    setState(() {
      _selectedBin = bin;
      _polylines.clear();
      _isLoadingRoute = _userLocation != null;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(bin.latitude, bin.longitude), 16),
    );
    if (_userLocation != null) {
      await _drawRoute(
        LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
        LatLng(bin.latitude, bin.longitude),
      );
    }
    if (mounted) setState(() => _isLoadingRoute = false);
  }

  void _clearSelection() => setState(() {
    _selectedBin = null;
    _polylines.clear();
  });

  // ── Walking route via Directions API ────────────────────────────────────────
  Future<void> _drawRoute(LatLng from, LatLng to) async {
    if (_kGoogleApiKey.isEmpty) {
      debugPrint('❌ API key is empty');
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${from.latitude},${from.longitude}'
        '&destination=${to.latitude},${to.longitude}'
        '&mode=walking'
        '&key=$_kGoogleApiKey',
      );

      debugPrint('🌐 Calling: $uri');

      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      debugPrint('📦 Status: ${data['status']}');
      debugPrint('📦 Full response: ${response.body}');

      if (data['status'] != 'OK') {
        debugPrint(
          '❌ Directions API error: ${data['status']} — ${data['error_message'] ?? 'no message'}',
        );
        if (mounted) setState(() => _isLoadingRoute = false);
        return;
      }

      // Decode the polyline
      final points = data['routes'][0]['overview_polyline']['points'] as String;
      final coords = _decodePolyline(points);

      if (!mounted) return;
      setState(() {
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: AppTheme.primary,
              width: 5,
              points: coords,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          );
        _isLoadingRoute = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_latLngBounds(from, to), 80),
      );
    } catch (e, stack) {
      debugPrint('❌ _drawRoute failed: $e');
      debugPrint(stack.toString());
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  // Built-in polyline decoder — no package needed
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  LatLngBounds _latLngBounds(LatLng a, LatLng b) => LatLngBounds(
    southwest: LatLng(
      min(a.latitude, b.latitude),
      min(a.longitude, b.longitude),
    ),
    northeast: LatLng(
      max(a.latitude, b.latitude),
      max(a.longitude, b.longitude),
    ),
  );

  // ── Haversine distance ───────────────────────────────────────────────────────
  double _distanceTo(Bin bin) {
    if (_userLocation == null) return 0;
    const R = 6371000.0;
    final lat1 = _userLocation!.latitude! * pi / 180;
    final lat2 = bin.latitude * pi / 180;
    final dLat = (bin.latitude - _userLocation!.latitude!) * pi / 180;
    final dLon = (bin.longitude - _userLocation!.longitude!) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _formatDistance(double m) =>
      m < 1000 ? '${m.round()} m.' : '${(m / 1000).toStringAsFixed(1)} km.';

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCamera,
          onMapCreated: (c) => _mapController = c,
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: _locationGranted,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onTap: (_) => _clearSelection(),
        ),

        // Loading banner
        if (_isLoadingRoute)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _Pill(
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Calculating route...',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Legend
        const Positioned(top: 12, right: 12, child: _MapLegend()),

        // My-location FAB
        Positioned(
          right: 12,
          bottom: _selectedBin != null ? 210 : 24,
          child: FloatingActionButton.small(
            heroTag: 'myLocation',
            backgroundColor: Colors.white,
            elevation: 4,
            onPressed: _goToMyLocation,
            child: Icon(Icons.my_location, color: AppTheme.primary),
          ),
        ),

        // Bin info card
        if (_selectedBin != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BinInfoCard(
              bin: _selectedBin!,
              distance: _userLocation != null
                  ? _formatDistance(_distanceTo(_selectedBin!))
                  : null,
              onClose: _clearSelection,
              onNavigate: () => _selectBin(_selectedBin!),
              onViewDetails: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BinDetailsPage(bin: _selectedBin!),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BinInfoCard extends StatelessWidget {
  final Bin bin;
  final String? distance;
  final VoidCallback onClose, onNavigate, onViewDetails;

  const _BinInfoCard({
    required this.bin,
    required this.distance,
    required this.onClose,
    required this.onNavigate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getBinColor(bin.binType);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle + close
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, size: 20, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Icon + name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete_outline, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bin.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bin.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type + distance
            Row(
              children: [
                _TypeChip(type: bin.binType, color: color),
                const Spacer(),
                if (distance != null) ...[
                  Icon(
                    Icons.straighten,
                    size: 15,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distance!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.info_outline, size: 17),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation, size: 17),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

class _TypeChip extends StatelessWidget {
  final String type;
  final Color color;
  const _TypeChip({required this.type, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color),
    ),
    child: Text(
      AppTheme.getBinTypeName(type),
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
      ],
    ),
    child: child,
  );
}

class _MapLegend extends StatefulWidget {
  const _MapLegend();
  @override
  State<_MapLegend> createState() => _MapLegendState();
}

class _MapLegendState extends State<_MapLegend> {
  bool _open = false;
  static const _entries = [
    ('green', 'Wet Waste'),
    ('yellow', 'Recycle'),
    ('red', 'Hazardous'),
    ('orange', 'General'),
  ];
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _open = !_open),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.layers_outlined, size: 15),
              const SizedBox(width: 4),
              const Text(
                'Legend',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Icon(_open ? Icons.expand_less : Icons.expand_more, size: 15),
            ],
          ),
          if (_open) ...[
            const SizedBox(height: 6),
            for (final (type, label) in _entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppTheme.getBinColor(type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
          ],
        ],
      ),
    ),
  );
}
