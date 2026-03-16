import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crimereport/core/services/complaint_service.dart';
import 'package:crimereport/features/auth/presentation/pages/login_screen.dart';
import 'package:crimereport/config/api_config.dart';
import 'package:crimereport/l10n/app_localizations.dart';
import 'package:crimereport/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ComplaintService _complaintService = ComplaintService();
  String _userName = '';
  String _userEmail = '';
  String? _profilePicUrl;
  List<dynamic> _complaints = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userName.isEmpty) {
      _userName = AppLocalizations.of(context)!.loading;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? AppLocalizations.of(context)!.user;
      _userEmail = prefs.getString('user_email') ?? AppLocalizations.of(context)!.noEmail;
      _profilePicUrl = prefs.getString('profile_pic');
    });

    if (_userEmail != AppLocalizations.of(context)!.noEmail) {
      try {
        final complaints = await _complaintService.getMyComplaints(_userEmail);
        if (mounted) {
          setState(() {
            _complaints = complaints;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadProfilePic() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/upload-profile-pic');
      final request = http.MultipartRequest('POST', uri);
      request.fields['email'] = _userEmail;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse URL from response
        final urlMatch = RegExp(r'"profile_pic":"([^"]+)"').firstMatch(body);
        final newUrl = urlMatch?.group(1);
        if (newUrl != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_pic', newUrl);
          if (mounted) setState(() => _profilePicUrl = newUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.profilePicUpdated),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.uploadFailed}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    await prefs.clear();
    // Keep the language code after logout
    if (languageCode != null) {
      await prefs.setString('language_code', languageCode);
    }
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _changeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLocale = localeNotifier.value.languageCode;
    final newLocale = currentLocale == 'en' ? 'ml' : 'en';
    
    await prefs.setString('language_code', newLocale);
    localeNotifier.value = Locale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, size: 20, color: Colors.red),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 30),
                    _buildReportsListHeader(),
                    const SizedBox(height: 16),
                    _buildReportsList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _pickAndUploadProfilePic,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: ClipOval(
                    child: _isUploading
                        ? Container(
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : _profilePicUrl != null
                            ? Image.network(
                                _profilePicUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildNoPic(),
                              )
                            : _buildNoPic(),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickAndUploadProfilePic,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 16, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _changeLanguage,
            icon: const Icon(Icons.language, size: 18),
            label: Text(AppLocalizations.of(context)!.changeLanguage),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
              backgroundColor: const Color(0xFFE3F2FD),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPic() {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.person, size: 60, color: Color(0xFFBDBDBD)),
    );
  }

  Widget _buildStatsRow() {
    int total = _complaints.length;
    int pending = _complaints.where((c) => c['status'] == 'Pending' || c['status'] == null).length;
    int reviewed = _complaints.where((c) => c['status'] != 'Pending' && c['status'] != null).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildStatItem(AppLocalizations.of(context)!.reported, total.toString())),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(child: _buildStatItem(AppLocalizations.of(context)!.reviewed, reviewed.toString())),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(child: _buildStatItem(AppLocalizations.of(context)!.pending, pending.toString())),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildReportsListHeader() {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.myCrimeReports,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
      ],
    );
  }

  Widget _buildReportsList() {
    if (_complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.noReportsFound, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _complaints.length,
      itemBuilder: (context, index) {
        final complaint = _complaints[index];
        final title = complaint['title'] ?? 'No Title';
        final type = complaint['crime_type'] ?? 'General';
        final status = complaint['status'] ?? 'Pending';
        final createdAt = complaint['created_at'] != null
            ? DateTime.tryParse(complaint['created_at'])
            : null;
        final dateStr = createdAt != null
            ? '${createdAt.day.toString().padLeft(2, '0')} ${_monthName(createdAt.month, context)} ${createdAt.year}'
            : AppLocalizations.of(context)!.unknownDate;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'Resolved' ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'Resolved' ? Colors.green : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(type, style: const TextStyle(fontSize: 13, color: Color(0xFF1E88E5), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _monthName(int month, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = [l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun, l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec];
    return months[month - 1];
  }
}
