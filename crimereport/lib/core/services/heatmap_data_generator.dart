import 'dart:math';
import '../../features/home/data/models/heatmap_point.dart';

class HeatmapDataGenerator {
  static List<HeatmapPoint> generateSampleHeatmapPoints(
    double centerLat,
    double centerLng,
  ) {
    final random = Random();
    final List<HeatmapPoint> points = [];

    // Generate 50 sample points
    for (int i = 0; i < 50; i++) {
      // Random offset within approximately 1-2 km radius
      // 1 degree latitude is approx 111 km
      // 0.01 degrees is approx 1.1 km

      double latOffset = (random.nextDouble() - 0.5) * 0.02; // +/- 0.01 deg
      double lngOffset = (random.nextDouble() - 0.5) * 0.02; // +/- 0.01 deg

      // Random intensity between 0.2 and 1.0 (to avoid invisible points)
      double intensity = 0.2 + (random.nextDouble() * 0.8);

      points.add(
        HeatmapPoint(
          latitude: centerLat + latOffset,
          longitude: centerLng + lngOffset,
          intensity: intensity,
        ),
      );
    }

    return points;
  }
}
