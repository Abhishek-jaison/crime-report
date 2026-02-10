import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'package:crimereport/features/auth/presentation/pages/welcome_screen.dart';
import 'package:crimereport/features/complaint/presentation/pages/complaint_registration_screen.dart';
import 'package:crimereport/features/home/presentation/pages/crime_heatmap_screen.dart';
import 'package:crimereport/core/services/police_station_service.dart';
import 'package:crimereport/features/home/data/models/police_station_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PoliceStation? _nearestStation;
  bool _isLoadingStation = false;
  String _stationError = '';

  @override
  void initState() {
    super.initState();
    _fetchNearestPoliceStation();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data (or just isVerified)

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  Future<void> _makeEmergencyCall(BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch dialer.")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _fetchNearestPoliceStation() async {
    setState(() {
      _isLoadingStation = true;
      _stationError = '';
    });

    try {
      // 1. Check permissions & Get Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingStation = false;
          _stationError = 'Location services disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingStation = false;
            _stationError = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingStation = false;
          _stationError = 'Location permission permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // 2. Fetch Stations
      final service = PoliceStationService();
      final stations = await service.fetchNearbyStations(
        position.latitude,
        position.longitude,
      );

      if (stations.isNotEmpty) {
        // Service already calculating distance and we could sort
        // Assuming service returns sorted or we just take the first one
        // Let's sort to be sure
        stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

        if (mounted) {
          setState(() {
            _nearestStation = stations.first;
            _isLoadingStation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStation = false;
            _stationError = 'No police stations found nearby';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStation = false;
          _stationError = 'Failed to load station: $e';
        });
      }
    }
  }

  void _openMap(double lat, double lng) async {
    // 1. Try launching native map app (geo: scheme)
    final geoUrl = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    try {
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
        return;
      }
    } catch (_) {
      // Ignore error and try next method
    }

    // 2. Fallback to Google Maps Web URL (https: scheme)
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open maps (no app found)")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error opening map: $e")));
      }
    }
  }

  Future<void> _sendSOSMessage(BuildContext context) async {
    // 1. Check permissions - Reuse logic or simplify since usually done in _fetchNearestPoliceStation
    // But SOS is critical, so re-check
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permissions are permanently denied."),
          ),
        );
      }
      return;
    }

    // 2. Get Location
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fetching location...")));
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Compose SMS
      final String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      final String message =
          "SOS! I need help. My current location: $googleMapsUrl";

      // 4. Send SMS Intent
      final Uri smsLaunchUri = Uri(
        scheme: 'sms',
        path: '1234567890', // Placeholder emergency contact
        queryParameters: <String, String>{'body': message},
      );

      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch SMS app.")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
      }
    }
  }

  void _triggerSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("URGENT: SOS ACITON"),
        content: const Text("Choose an emergency action:"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CANCEL"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _sendSOSMessage(context);
            },
            icon: const Icon(Icons.sms),
            label: const Text("SEND LOCATION"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _makeEmergencyCall(context);
            },
            icon: const Icon(Icons.call),
            label: const Text("CALL 112"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Reporting Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to the Dashboard!",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 30),

              // Police Station Card
              if (_isLoadingStation)
                const CircularProgressIndicator()
              else if (_stationError.isNotEmpty)
                Text(
                  "Station Error: $_stationError",
                  style: const TextStyle(color: Colors.red),
                )
              else if (_nearestStation != null)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Nearest Police Station",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text(
                          _nearestStation!.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nearestStation!.address,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Distance: ${_nearestStation!.distance?.toStringAsFixed(0)} meters",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openMap(
                            _nearestStation!.lat,
                            _nearestStation!.lng,
                          ),
                          icon: const Icon(Icons.map),
                          label: const Text("View on Map"),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ComplaintRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem),
                label: const Text("Register Complaint"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CrimeHeatmapScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text("View Crime Map"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () => _triggerSOS(context),
            backgroundColor: Colors.red,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sos, size: 30, color: Colors.white),
                Text(
                  "SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
