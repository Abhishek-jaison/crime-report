import 'dart:math';
import '../../features/home/data/models/heatmap_point.dart';

class HeatmapDataGenerator {
  static List<HeatmapPoint> generateSampleHeatmapPoints(
    double centerLat,
    double centerLng,
  ) {
    // Use a fixed seed for deterministic results
    final random = Random(42);
    final List<HeatmapPoint> points = [];

    // Define Base Ring configurations
    // Strategy: 2 Rings, Total 6 Clusters
    // We will add random jitter to the exact positions to break the pattern
    final rings = [
      {
        'distance': 2.2, // Base Distance: 2.2km
        'clusters': 3,
        'startAngle': random.nextDouble() * 360, // Random start angle
      },
      {
        'distance': 4.5, // Base Distance: 4.5km
        'clusters': 3,
        'startAngle': random.nextDouble() * 360, // Different random start
      },
    ];

    for (int ringIndex = 0; ringIndex < rings.length; ringIndex++) {
      final ring = rings[ringIndex];
      double baseDistance = ring['distance'] as double;
      int clusterCount = ring['clusters'] as int;
      double startAngle = ring['startAngle'] as double;

      double angleStep = 360.0 / clusterCount;

      for (int i = 0; i < clusterCount; i++) {
        // Add random jitter to angle (+/- 20 degrees)
        double angleJitter = (random.nextDouble() - 0.5) * 40;
        double bearing = startAngle + (i * angleStep) + angleJitter;

        // Add random jitter to distance (+/- 0.8 km)
        double distJitter = (random.nextDouble() - 0.5) * 1.6;
        double distance = baseDistance + distJitter;

        // Generate an organic, multi-blob cluster
        points.addAll(
          _generateOrganicCluster(
            random,
            centerLat,
            centerLng,
            distanceKm: distance,
            bearingDeg: bearing,
          ),
        );
      }
    }

    return points;
  }

  /// Generates an irregular, organic-shaped cluster composed of multiple overlapping sub-blobs.
  static List<HeatmapPoint> _generateOrganicCluster(
    Random random,
    double centerLat,
    double centerLng, {
    required double distanceKm,
    required double bearingDeg,
  }) {
    List<HeatmapPoint> clusterPoints = [];

    // 1. Calculate Main Cluster Center
    double latPerKm = 1 / 111.0;
    double lngPerKm = 1 / (111.0 * cos(centerLat * pi / 180));
    double bearingRad = bearingDeg * pi / 180;

    double mainLat = centerLat + (distanceKm * latPerKm * cos(bearingRad));
    double mainLng = centerLng + (distanceKm * lngPerKm * sin(bearingRad));

    // 2. Create 3-5 sub-blobs around the main center to form an irregular shape
    int blobCount = 3 + random.nextInt(3); // 3 to 5 blobs

    for (int i = 0; i < blobCount; i++) {
      // Offset sub-blob center from main center (up to 400m away)
      double offsetR = 0.4 * sqrt(random.nextDouble());
      double offsetTheta = random.nextDouble() * 2 * pi;

      double blobLat = mainLat + (offsetR * latPerKm * cos(offsetTheta));
      double blobLng = mainLng + (offsetR * lngPerKm * sin(offsetTheta));

      // Determine blob characteristics
      // Use different sizes and intensities to create the "gradient" effect naturally

      // Some blobs are "Cores" (Red/High), some are "Spread" (Yellow/Blue/Low)
      // 30% chance of being a Hot High Intensity Core
      bool isCore = random.nextDouble() < 0.3;

      if (isCore) {
        // High Intensity Core Blob
        // Small radius, high intensity
        clusterPoints.addAll(
          _generatePointsInRadius(
            random,
            blobLat,
            blobLng,
            radiusKm: 0.2, // 200m tight core
            count: 15,
            minIntensity: 0.8,
            maxIntensity: 1.0,
          ),
        );
      } else {
        // Medium/Low Spread Blob
        // Larger radius, lower intensity
        clusterPoints.addAll(
          _generatePointsInRadius(
            random,
            blobLat,
            blobLng,
            radiusKm: 0.5 + (random.nextDouble() * 0.3), // 500m - 800m radius
            count: 20,
            minIntensity: 0.2,
            maxIntensity: 0.6,
          ),
        );
      }
    }

    // Add a unifying low-intensity background layer for the whole cluster
    clusterPoints.addAll(
      _generatePointsInRadius(
        random,
        mainLat,
        mainLng,
        radiusKm: 0.8, // 800m wide background wash
        count: 10,
        minIntensity: 0.1,
        maxIntensity: 0.3,
      ),
    );

    return clusterPoints;
  }

  static List<HeatmapPoint> _generatePointsInRadius(
    Random random,
    double centerLat,
    double centerLng, {
    required double radiusKm,
    required int count,
    required double minIntensity,
    required double maxIntensity,
  }) {
    List<HeatmapPoint> points = [];
    double latPerKm = 1 / 111.0;
    double lngPerKm = 1 / (111.0 * cos(centerLat * pi / 180));

    for (int i = 0; i < count; i++) {
      // Random point in circle
      double r = radiusKm * sqrt(random.nextDouble());
      double theta = random.nextDouble() * 2 * pi;

      double latOffset = r * latPerKm * cos(theta);
      double lngOffset = r * lngPerKm * sin(theta);

      double intensity =
          minIntensity + (random.nextDouble() * (maxIntensity - minIntensity));

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
