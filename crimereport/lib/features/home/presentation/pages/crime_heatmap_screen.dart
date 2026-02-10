import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:crimereport/core/services/location_service.dart';

import 'package:crimereport/features/home/data/models/heatmap_point.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:crimereport/core/services/heatmap_data_generator.dart';

class CrimeHeatmapScreen extends StatefulWidget {
  const CrimeHeatmapScreen({super.key});

  @override
  State<CrimeHeatmapScreen> createState() => _CrimeHeatmapScreenState();
}

class _CrimeHeatmapScreenState extends State<CrimeHeatmapScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isLoading = true;
  List<WeightedLatLng> _heatmapData = [];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      // Generate heatmap data around the user
      final points = HeatmapDataGenerator.generateSampleHeatmapPoints(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _heatmapData = points
            .map(
              (HeatmapPoint p) =>
                  WeightedLatLng(LatLng(p.latitude, p.longitude), p.intensity),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Default location (e.g., New Delhi) if permission denied
        _currentLocation = const LatLng(28.6139, 77.2090);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crime Heatmap")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.crimereport',
                ),
                if (_heatmapData.isNotEmpty)
                  HeatMapLayer(
                    heatMapDataSource: InMemoryHeatMapDataSource(
                      data: _heatmapData,
                    ),
                    heatMapOptions: HeatMapOptions(
                      gradient: {
                        0.25: Colors.blue,
                        0.55: Colors.yellow,
                        0.85: Colors.red,
                        1.0: Colors.deepOrange,
                      },
                      minOpacity: 0.1,
                      radius: 50,
                    ),
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
