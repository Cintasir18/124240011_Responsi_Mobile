import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/store_data.dart';
import '../models/store.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final MapController _mapController = MapController();
  Position? _userPosition;
  bool _isLoading = true;
  String? _locationError;
  int? _selectedStoreId;

  List<Store> get _sortedStores {
    final stores = [...StoreData.stores];
    final position = _userPosition;
    if (position == null) return stores;

    stores.sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));
    return stores;
  }

  double _distanceTo(Store store) => Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        store.latitude,
        store.longitude,
      );

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Layanan lokasi perangkat sedang nonaktif.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi belum diberikan.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _isLoading = false;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 12.5);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _focusStore(Store store) {
    setState(() => _selectedStoreId = store.id);
    _mapController.move(LatLng(store.latitude, store.longitude), 14);
  }

  @override
  Widget build(BuildContext context) {
    final stores = _sortedStores;
    final userPosition = _userPosition;
    final mapCenter = userPosition == null
        ? LatLng(
            StoreData.stores.first.latitude,
            StoreData.stores.first.longitude,
          )
        : LatLng(userPosition.latitude, userPosition.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Toko Terdekat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            height: 300,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: mapCenter, initialZoom: 11.5),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.simulasi_res',
                ),
                MarkerLayer(
                  markers: [
                    ...StoreData.stores.map(
                      (store) => Marker(
                        point: LatLng(store.latitude, store.longitude),
                        width: 44,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _focusStore(store),
                          child: Icon(
                            Icons.location_on,
                            size: 42,
                            color: _selectedStoreId == store.id
                                ? Colors.deepOrange
                                : const Color(0xFF414936),
                          ),
                        ),
                      ),
                    ),
                    if (userPosition != null)
                      Marker(
                        point: mapCenter,
                        width: 38,
                        height: 38,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kunjungi toko lokal kami',
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar toko',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              if (_isLoading)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              else if (userPosition != null)
                IconButton(
                  tooltip: 'Perbarui lokasi',
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _loadUserLocation();
                  },
                  icon: const Icon(Icons.my_location),
                ),
            ],
          ),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jarak belum tersedia: $_locationError',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _locationError = null;
                      });
                      _loadUserLocation();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ...stores.map((store) {
            final distance = userPosition == null ? null : _distanceTo(store);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => _focusStore(store),
                leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
                title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${store.address}\n${store.description}'),
                isThreeLine: true,
                trailing: distance == null
                    ? const Icon(Icons.map_outlined)
                    : Text(
                        distance >= 1000
                            ? '${(distance / 1000).toStringAsFixed(1)} km'
                            : '${distance.round()} m',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
