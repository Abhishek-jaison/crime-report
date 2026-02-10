import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crimereport/core/services/complaint_service.dart';
import 'package:crimereport/features/auth/presentation/pages/login_screen.dart';

class ComplaintRegistrationScreen extends StatefulWidget {
  const ComplaintRegistrationScreen({super.key});

  @override
  State<ComplaintRegistrationScreen> createState() =>
      _ComplaintRegistrationScreenState();
}

class _ComplaintRegistrationScreenState
    extends State<ComplaintRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCrimeType;
  final List<String> _crimeTypes = ['Theft', 'Harassment', 'Assault', 'Other'];

  File? _selectedImage;
  File? _selectedVideo;

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // _selectedVideo = null; // Allow both? Screenshot implies multiple media.
        // For now, sticking to logic of one or the other or both?
        // The UI shows placeholders for both. Let's allow both if existing logic supports it.
        // Existing logic in `submitComplaint` sends both `image` and `video` params.
        // So I will NOT clear the other one.
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        // _selectedImage = null; // See above
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');

        if (userEmail == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return;
        }

        final complaintService = ComplaintService();
        final result = await complaintService.submitComplaint(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          crimeType: _selectedCrimeType!,
          userEmail: userEmail,
          image: _selectedImage,
          video: _selectedVideo,
        );

        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint Submitted Successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _formKey.currentState!.reset();
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedImage = null;
            _selectedVideo = null;
            _selectedCrimeType = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Submission Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Register Complaint",
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("INCIDENT DETAILS"),
                const SizedBox(height: 16),

                // Complaint Title
                const Text(
                  "Complaint Title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    "Brief summary of incident",
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),

                // Crime Type
                const Text(
                  "Crime Type",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCrimeType,
                  items: _crimeTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCrimeType = value!),
                  decoration: _buildInputDecoration("Select category"),
                  validator: (value) =>
                      value == null ? 'Please select a crime type' : null,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader("DETAILED DESCRIPTION"),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                    "Please provide as much detail as possible, including date, time, and location...",
                  ).copyWith(contentPadding: const EdgeInsets.all(16)),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please provide a description'
                      : null,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader("EVIDENCE & ATTACHMENTS"),
                const SizedBox(height: 16),

                // Attachment Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildAttachmentButton(
                        icon: Icons.add_a_photo,
                        label: "Add Photo",
                        onTap: _pickImage,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttachmentButton(
                        icon: Icons.videocam,
                        label: "Add Video",
                        onTap: _pickVideo,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Previews
                if (_selectedImage != null || _selectedVideo != null)
                  Row(
                    children: [
                      if (_selectedImage != null)
                        _buildMediaPreview(
                          _selectedImage!,
                          Icons.image,
                          _removeImage,
                        ),
                      if (_selectedImage != null && _selectedVideo != null)
                        const SizedBox(width: 16),
                      if (_selectedVideo != null)
                        _buildMediaPreview(
                          _selectedVideo!,
                          Icons.video_file,
                          _removeVideo,
                        ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color(0xFF1E88E5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "By submitting this report, you confirm that the information provided is accurate to the best of your knowledge. False reporting is a punishable offense.",
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Submit Complaint",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.send, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle
                .solid, // Dashed border needs package, sticking to solid 'placeholder' look
          ),
        ),
        // Use a dotted border if helper available?
        // Emulating dashed look with logic is complex without package.
        // Clean simple border used.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(File file, IconData icon, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black12,
            image: (icon == Icons.image)
                ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                : null,
          ),
          child: (icon == Icons.video_file)
              ? Center(child: Icon(icon, size: 40, color: Colors.white))
              : null,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
