class PoliceStation {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;
  double? distance; // Distance from user in meters

  PoliceStation({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
    this.distance,
  });

  factory PoliceStation.fromOsmJson(Map<String, dynamic> json) {
    final tags = json['tags'] ?? {};
    return PoliceStation(
      id: json['id'].toString(),
      name: tags['name'] ?? 'Police Station',
      address: _formatAddress(tags),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lon'] as num).toDouble(),
      rating: null, // OSM doesn't have standard ratings
    );
  }

  static String _formatAddress(Map<String, dynamic> tags) {
    List<String> parts = [];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);

    if (parts.isEmpty) return 'Location details not available';
    return parts.join(', ');
  }
}
