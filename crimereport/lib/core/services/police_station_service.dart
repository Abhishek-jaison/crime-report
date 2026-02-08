import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../features/home/data/models/police_station_model.dart';
import 'dart:async'; // Import for TimeoutException

class PoliceStationService {
  // List of Overpass API mirrors
  final List<String> _overpassMirrors = [
    'https://overpass-api.de/api/interpreter', // Main instance (often busy)
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter', // Russian mirror (often fast)
    'https://overpass.kumi.systems/api/interpreter', // Alternative mirror
    'https://lz4.overpass-api.de/api/interpreter', // Another mirror
  ];

  Future<List<PoliceStation>> fetchNearbyStations(
    double userLat,
    double userLng,
  ) async {
    // Query finds nodes with amenity=police within 5000m radius (increased slightly for better results)
    final String query =
        '[out:json];node(around:5000,$userLat,$userLng)["amenity"="police"];out;';

    // Iterate through mirrors until one succeeds
    for (String mirrorUrl in _overpassMirrors) {
      final String url = '$mirrorUrl?data=$query';

      try {
        print('Trying Overpass Mirror: $mirrorUrl');

        final response = await http
            .get(Uri.parse(url))
            .timeout(
              const Duration(
                seconds: 5,
              ), // Short timeout to fail fast and try next
              onTimeout: () {
                throw TimeoutException('Request timed out for $mirrorUrl');
              },
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['elements'] != null) {
            final List<dynamic> elements = data['elements'];

            List<PoliceStation> stations = elements
                .map((json) => PoliceStation.fromOsmJson(json))
                .toList();

            // Calculate distance for each station
            for (var station in stations) {
              station.distance = Geolocator.distanceBetween(
                userLat,
                userLng,
                station.lat,
                station.lng,
              );
            }

            // Sort by distance
            stations.sort(
              (a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0),
            );

            print('Success! Found ${stations.length} stations from $mirrorUrl');
            return stations;
          } else {
            // Empty response is valid, but we might want to try other mirrors if we are suspicious?
            // For now, accept empty valid response.
            return [];
          }
        } else {
          // If server error (500, 502, 504), continue loop
          print('Failed with status ${response.statusCode} from $mirrorUrl');
          if (response.statusCode >= 500) continue;
          // If 400 (bad request), break because query is likely wrong for all.
          if (response.statusCode == 400) break;
        }
      } catch (e) {
        print("Error fetching police stations from $mirrorUrl: $e");
        // Continue to next mirror on any exception (timeout, socket error, etc)
        continue;
      }
    }

    // If all mirrors fail
    print('All Overpass mirrors failed.');
    return [];
  }
}
