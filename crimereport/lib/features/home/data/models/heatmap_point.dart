class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity; // Weight of the crime point (e.g., 0.0 to 1.0)

  HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
  });

  @override
  String toString() {
    return 'HeatmapPoint(lat: $latitude, lng: $longitude, intensity: $intensity)';
  }
}
