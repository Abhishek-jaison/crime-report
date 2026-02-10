import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'package:crimereport/features/complaint/presentation/pages/complaint_registration_screen.dart';
import 'package:crimereport/features/home/presentation/pages/crime_heatmap_screen.dart';
import 'package:crimereport/core/services/police_station_service.dart';
import 'package:crimereport/features/home/data/models/police_station_model.dart';
import 'package:crimereport/features/auth/presentation/pages/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PoliceStation? _nearestStation;
  // Navigation Index
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNearestPoliceStation();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _sendSOSMessage() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Location disabled")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    final String message =
        "SOS! I need help. My current location: $googleMapsUrl";
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: '112',
      queryParameters: <String, String>{'body': message},
    );
    if (await canLaunchUrl(smsLaunchUri)) await launchUrl(smsLaunchUri);
  }

  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _fetchNearestPoliceStation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final service = PoliceStationService();
      final stations = await service.fetchNearbyStations(
        position.latitude,
        position.longitude,
      );
      if (stations.isNotEmpty) {
        stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        if (mounted) setState(() => _nearestStation = stations.first);
      }
    } catch (e) {
      // Handle silently
    }
  }

  void _openMapToStation() {
    if (_nearestStation != null) {
      final geoUrl = Uri.parse(
        "geo:${_nearestStation!.lat},${_nearestStation!.lng}?q=${_nearestStation!.lat},${_nearestStation!.lng}",
      );
      launchUrl(geoUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Finding nearest station...")),
      );
      _fetchNearestPoliceStation().then((_) {
        if (_nearestStation != null) _openMapToStation();
      });
    }
  }

  void _showSOSOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Emergency Action",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.red),
              title: const Text("Call 112"),
              onTap: () {
                Navigator.pop(context);
                _makeEmergencyCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.orange),
              title: const Text("Send Location via SMS"),
              onTap: () {
                Navigator.pop(context);
                _sendSOSMessage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildGridMenu(context),
              const SizedBox(height: 24),
              _buildSOSBanner(),
              const SizedBox(height: 24),
              _buildRecentReportsHeader(),
              const SizedBox(height: 16),
              _buildRecentReportsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "John Doe", // Placeholder name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE0CBA8), // Placeholder avatar color
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: const DecorationImage(
              // Using a generic placeholder if no image
              image: NetworkImage(
                "https://i.pravatar.cc/150?img=11",
              ), // Mock image
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "System Status: Active",
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "3 active patrols in your vicinity.",
                style: TextStyle(color: Color(0xFF546E7A), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridItem(
                context,
                icon: Icons.assignment,
                color: Colors.blue.shade100,
                iconColor: Colors.blue.shade800,
                title: "Register",
                subtitle: "Complaint",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ComplaintRegistrationScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGridItem(
                context,
                icon: Icons.map,
                color: Colors.lightBlue.shade50,
                iconColor: Colors.blue.shade800,
                title: "Heat Map",
                subtitle: "Crime Zones",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CrimeHeatmapScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGridItem(
                context,
                icon: Icons.local_police, // Shield icon replacement
                color: Colors.blue.shade50,
                iconColor: Colors.blue.shade800,
                title: "Police",
                subtitle: "Station Finder",
                onTap: _openMapToStation, // Use existing logic
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGridItem(
                context,
                icon: Icons.menu_book,
                color: Colors.blue.shade50,
                iconColor: Colors.blue.shade800,
                title: "Guidelines",
                subtitle: "Legal Info",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Guidelines Coming Soon")),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSBanner() {
    return GestureDetector(
      onTap: _showSOSOptions,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.red.shade100, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFEF9A9A), // Light red
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SOS EMERGENCY",
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Instant Help & Location Share",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Reports",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "See All",
            style: TextStyle(
              color: Color(0xFF1E88E5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReportsList() {
    return Column(
      children: [
        _buildReportItem(
          title: "Theft Reported",
          time: "2 hours ago • Campus North",
          status: "PENDING",
          statusColor: Colors.grey.shade200,
          statusTextColor: Colors.grey.shade700,
          icon: Icons.warning_amber_rounded,
          iconBg: const Color(0xFFFFF9C4), // Yellow
          iconColor: const Color(0xFFFBC02D),
        ),
        const SizedBox(height: 16),
        _buildReportItem(
          title: "Station Visit Scheduled",
          time: "Yesterday • Precinct 04",
          status: "CLOSED",
          statusColor: Colors.green.shade50,
          statusTextColor: Colors.green,
          icon: Icons.check_circle_outline,
          iconBg: Colors.green.shade50,
          iconColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildReportItem({
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 0) {
          // Home
        } else if (index == 3) {
          // Profile -> Logout logic for now
          _logout(context);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Support',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
