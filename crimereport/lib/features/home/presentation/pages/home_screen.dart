import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';

import 'package:crimereport/core/services/sos_service.dart';
import 'package:crimereport/features/complaint/presentation/pages/complaint_registration_screen.dart';
import 'package:crimereport/features/home/presentation/pages/crime_heatmap_screen.dart';
import 'package:crimereport/core/services/police_station_service.dart';
import 'package:crimereport/features/home/data/models/police_station_model.dart';
import 'package:crimereport/features/profile/presentation/pages/profile_screen.dart';
import 'package:crimereport/core/services/complaint_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PoliceStation? _nearestStation;
  int _selectedIndex = 0;
  String? _userName;
  final ComplaintService _complaintService = ComplaintService();
  final SOSService _sosService = SOSService();
  List<dynamic> _recentComplaints = [];
  bool _isLoadingComplaints = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchNearestPoliceStation();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
    });
    final email = prefs.getString('user_email');
    if (email != null) {
      _fetchRecentComplaints(email);
    } else {
      setState(() => _isLoadingComplaints = false);
    }
  }

  Future<void> _fetchRecentComplaints(String email) async {
    try {
      final complaints = await _complaintService.getMyComplaints(email);
      if (mounted) {
        setState(() {
          complaints.sort((a, b) {
            final dateA = DateTime.parse(
              a['created_at'] ?? DateTime.now().toString(),
            );
            final dateB = DateTime.parse(
              b['created_at'] ?? DateTime.now().toString(),
            );
            return dateB.compareTo(dateA);
          });
          _recentComplaints = complaints.take(3).toList();
          _isLoadingComplaints = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingComplaints = false);
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

    // TRIGGER SOS API
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    _sosService
        .sendSOSAlert(
          lat: position.latitude.toString(),
          long: position.longitude.toString(),
          userEmail: email,
        )
        .then((result) {
          if (mounted) {
            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("SOS Alert Sent to Server!"),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              // Silently fail or minimal error to avoid panic?
              // Maybe just log it.
              print("Failed to send SOS: ${result['message']}");
            }
          }
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: FrostedBottomBar(
        opacity: 0.6, // Slightly more transparent to let blur show through
        sigmaX: 20, // Increased blur for "frosted" look
        sigmaY: 20,
        borderRadius: BorderRadius.circular(500),
        duration: const Duration(milliseconds: 500),
        hideOnScroll: false,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
        width: MediaQuery.of(context).size.width * 0.85,
        bottomBarColor: Colors.transparent, // We handle colors in the child
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ), // Glass edge
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.4), // Light reflection
                Colors.white.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(
                0,
                Icons.home_rounded,
                Icons.home_outlined,
                isLeft: true,
              ),
              _buildNavItem(
                1,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                isLeft: false,
              ),
            ],
          ),
        ),
        body: (context, controller) {
          return IndexedStack(
            index: _selectedIndex,
            children: [_buildHomeContent(), const ProfileScreen()],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon, {
    required bool isLeft,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            // Primary color for selected, transparent for unselected (showing crystal bg)
            color: isSelected
                ? const Color(0xFF1E88E5).withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(500) : Radius.zero,
              right: !isLeft ? const Radius.circular(500) : Radius.zero,
            ),
          ),
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            // White for selected, dark grey for unselected to contrast with glass
            color: isSelected ? Colors.white : Colors.black54,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            100,
          ), // Extra bottom padding for nav bar
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
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _userName ?? "User",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Switch to Profile Tab instead of pushing
            setState(() => _selectedIndex = 1);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE0CBA8), // Placeholder avatar color
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
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
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ComplaintRegistrationScreen(),
                    ),
                  );
                  // Auto-refresh when returning
                  _loadUserData();
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
    return SwipeableSOSButton(onTrigger: _sendSOSMessage);
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
    if (_isLoadingComplaints) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentComplaints.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text(
              "No recent activity",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentComplaints.map((complaint) {
        final title = complaint['title'] ?? 'No Title';
        final status = complaint['status'] ?? 'Pending';
        // Use CURRENT DATE as requested
        final now = DateTime.now();
        final date =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        // Show only date (already formatted above)
        final timeAgo = date;

        // Color logic
        Color statusColor = Colors.grey.shade200;
        Color statusTextColor = Colors.grey.shade700;
        IconData icon = Icons.info_outline;
        Color iconBg = Colors.grey.shade100;
        Color iconColor = Colors.grey;

        if (status == 'Pending') {
          statusColor = const Color(0xFFFFF9C4); // Yellow Light
          statusTextColor = const Color(0xFFFBC02D); // Yellow Dark
          icon = Icons.warning_amber_rounded;
          iconBg = const Color(0xFFFFF9C4);
          iconColor = const Color(0xFFFBC02D);
        } else if (status == 'Resolved') {
          statusColor = Colors.green.shade50;
          statusTextColor = Colors.green;
          icon = Icons.check_circle_outline;
          iconBg = Colors.green.shade50;
          iconColor = Colors.green;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildReportItem(
            title: title,
            time: timeAgo,
            status: status.toUpperCase(),
            statusColor: statusColor,
            statusTextColor: statusTextColor,
            icon: icon,
            iconBg: iconBg,
            iconColor: iconColor,
          ),
        );
      }).toList(),
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
}

class SwipeableSOSButton extends StatefulWidget {
  final Future<void> Function() onTrigger;

  const SwipeableSOSButton({super.key, required this.onTrigger});

  @override
  State<SwipeableSOSButton> createState() => _SwipeableSOSButtonState();
}

class _SwipeableSOSButtonState extends State<SwipeableSOSButton> {
  double _dragValue = 0.0;
  bool _isSent = false;
  final double _threshold = 0.7;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double sliderWidth) {
    if (_isSent) return;
    setState(() {
      _dragValue += details.primaryDelta! / sliderWidth;
      _dragValue = _dragValue.clamp(0.0, 1.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isSent) return;
    if (_dragValue > _threshold) {
      _triggerSOS();
    } else {
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _dragValue = 1.0;
      _isSent = true;
    });

    await widget.onTrigger();

    // 10s Timer to reset
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isSent = false;
          _dragValue = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final knobSize = 60.0;
        final padding = 4.0;
        final sliderWidth = width - knobSize - (padding * 2);

        return Container(
          height: knobSize + (padding * 2),
          decoration: BoxDecoration(
            color: _isSent ? Colors.green.shade600 : Colors.red.shade600,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: (_isSent ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Center(
                child: Text(
                  _isSent ? "SOS SENT!" : "SWIPE FOR HELP  >>>",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // Slider Knob
              Positioned(
                left: padding + (_dragValue * sliderWidth),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onHorizontalDragUpdate(details, sliderWidth),
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isSent ? Icons.check_rounded : Icons.sos_rounded,
                      color: _isSent
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
