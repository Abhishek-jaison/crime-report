import 'package:flutter/material.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF1E88E5),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Safety & Legal Guidelines',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      ),
                    ),
                  ),
                  // Decorative pattern
                  Opacity(
                    opacity: 0.1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                      itemCount: 80,
                      itemBuilder: (_, i) => Icon(
                        i % 3 == 0 ? Icons.shield : i % 3 == 1 ? Icons.local_police : Icons.security,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Icon(Icons.menu_book, size: 60, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    icon: Icons.report_problem,
                    color: const Color(0xFF1E88E5),
                    title: 'How to File a Complaint',
                    items: [
                      'Open the app and tap "Register Complaint" from the home screen.',
                      'Provide a clear, factual title and a detailed description of the incident.',
                      'Select the appropriate crime type from the list (e.g., Theft, Assault).',
                      'Attach relevant photos or video evidence if available.',
                      'Submit the complaint — you will receive a case ID for tracking.',
                      'You can track your complaint status in the Profile section.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.emergency,
                    color: Colors.red,
                    title: 'Using the SOS Feature',
                    items: [
                      'In life-threatening situations, use the SOS slider on the home screen.',
                      'Slide fully to the right to trigger an emergency alert.',
                      'Your GPS location is automatically shared with authorities.',
                      'The SOS alert is dispatched to the nearest response team.',
                      'Do NOT misuse the SOS feature — false alarms are a punishable offence.',
                      'Ensure location permissions are enabled for SOS to work correctly.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.gavel,
                    color: const Color(0xFF7B1FA2),
                    title: 'Your Legal Rights',
                    items: [
                      'You have the right to file a First Information Report (FIR) at any police station.',
                      'FIR registration cannot be refused by police officers — it is your right.',
                      'You may file a complaint online or in person at the nearest station.',
                      'You have the right to receive a copy of the FIR free of charge.',
                      'Witnesses and complainants are protected under Indian law from retaliation.',
                      'If police refuse to file an FIR, approach the Superintendent of Police.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.privacy_tip,
                    color: const Color(0xFF2E7D32),
                    title: 'Privacy & Data Protection',
                    items: [
                      'Your personal data is securely stored and encrypted.',
                      'Your identity is not disclosed publicly. Only authorised officers see your details.',
                      'Evidence (photos/videos) you upload is stored on secure cloud servers.',
                      'You may request deletion of your account and associated data.',
                      'We do not share your information with third parties.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.warning_amber,
                    color: const Color(0xFFF57C00),
                    title: 'Responsible Reporting',
                    items: [
                      'Only report genuine incidents — false complaints are a criminal offence.',
                      'Provide accurate information to help authorities respond effectively.',
                      'Do not include personal opinions; stick to facts and observable events.',
                      'Filing false reports may result in legal action against the complainant.',
                      'Complaints can be withdrawn, but this does not erase the record.',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildEmergencyNumbers(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF424242),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyNumbers() {
    final numbers = [
      {'label': 'Police', 'number': '100', 'icon': Icons.local_police, 'color': const Color(0xFF1E88E5)},
      {'label': 'Ambulance', 'number': '108', 'icon': Icons.local_hospital, 'color': Colors.red},
      {'label': 'Women Helpline', 'number': '1091', 'icon': Icons.support_agent, 'color': const Color(0xFF7B1FA2)},
      {'label': 'Emergency', 'number': '112', 'icon': Icons.emergency, 'color': Colors.red.shade800},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_in_talk, color: Colors.red, size: 22),
                SizedBox(width: 12),
                Text(
                  'Emergency Contact Numbers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: numbers.map((n) {
                final color = n['color'] as Color;
                return Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(n['icon'] as IconData, color: color, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            n['number'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            n['label'] as String,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
