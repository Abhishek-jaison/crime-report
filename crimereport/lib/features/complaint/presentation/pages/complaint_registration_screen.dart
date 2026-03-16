import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crimereport/core/services/complaint_service.dart';
import 'package:crimereport/features/auth/presentation/pages/login_screen.dart';
import 'package:crimereport/l10n/app_localizations.dart';

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
  // Internal fixed values for backend, but we will localize them in the UI
  final List<String> _crimeTypes = ['Theft', 'Harassment', 'Assault', 'Other'];

  File? _selectedImage;
  File? _selectedVideo;
  File? _recordedAudio;

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Audio Recording states
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
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

  // --- Audio Recording Logic ---

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _recordedAudio = null;
          _audioPath = null;
        });
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
          _recordedAudio = File(path);
        });
      }
    } catch (e) {
      debugPrint("Stop recording error: $e");
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath != null) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
      }
    }
  }

  void _removeAudio() {
    setState(() {
      _audioPath = null;
      _recordedAudio = null;
      _isPlaying = false;
    });
    _audioPlayer.stop();
  }

  // -----------------------------

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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorNotLoggedIn),
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
          audio: _recordedAudio,
        );

        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.successSubmitted),
              backgroundColor: Colors.green,
            ),
          );

          _formKey.currentState!.reset();
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedImage = null;
            _selectedVideo = null;
            _recordedAudio = null;
            _audioPath = null;
            _selectedCrimeType = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? AppLocalizations.of(context)!.errorFailed),
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
        title: Text(
          AppLocalizations.of(context)!.registerComplaint,
          style: const TextStyle(
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
                _buildSectionHeader(AppLocalizations.of(context)!.incidentDetails),
                const SizedBox(height: 16),

                // Complaint Title
                Text(
                  AppLocalizations.of(context)!.complaintTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.detailedSummary,
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? AppLocalizations.of(context)!.errorTitle
                      : null,
                ),
                const SizedBox(height: 16),

                // Crime Type
                Text(
                  AppLocalizations.of(context)!.crimeType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCrimeType,
                  items: _crimeTypes.map((type) {
                    // Localize crime types
                    String label = type;
                    final l10n = AppLocalizations.of(context)!;
                    if (type == 'Theft') label = l10n.theft;
                    else if (type == 'Harassment') label = l10n.harassment;
                    else if (type == 'Assault') label = l10n.assault;
                    else if (type == 'Other') label = l10n.other;
                    
                    return DropdownMenuItem(value: type, child: Text(label));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCrimeType = value!),
                  decoration: _buildInputDecoration(AppLocalizations.of(context)!.selectCategory),
                  validator: (value) =>
                      value == null ? AppLocalizations.of(context)!.errorCrimeType : null,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(AppLocalizations.of(context)!.detailedDescription),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.descriptionHint,
                  ).copyWith(contentPadding: const EdgeInsets.all(16)),
                  validator: (value) => (value == null || value.isEmpty)
                      ? AppLocalizations.of(context)!.errorDescription
                      : null,
                ),

                const SizedBox(height: 16),
                
                // Voice Note Recording (WhatsApp Style)
                Text(
                  AppLocalizations.of(context)!.voiceNote,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                
                if (_recordedAudio == null) ...[
                  // Recording UI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isRecording ? Colors.red.shade200 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_isRecording) ...[
                          const Icon(Icons.mic, color: Colors.red, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.recording,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: _stopRecording,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Icon(Icons.stop, color: Colors.white, size: 20),
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.mic_none, color: Colors.grey, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.holdToRecord,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          GestureDetector(
                            onTap: _startRecording,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E88E5),
                              ),
                              child: const Icon(Icons.mic, color: Colors.white, size: 20),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ] else ...[
                  // Playback UI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF1E88E5)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _playAudio,
                          child: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: const Color(0xFF1E88E5),
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          // Simple visualizer placeholder
                          child: Row(
                            children: [
                              _AudioBar(height: 12), _AudioBar(height: 18), _AudioBar(height: 24),
                              _AudioBar(height: 14), _AudioBar(height: 20), _AudioBar(height: 10),
                              _AudioBar(height: 16), _AudioBar(height: 22), _AudioBar(height: 14),
                              _AudioBar(height: 18), _AudioBar(height: 10), _AudioBar(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _removeAudio,
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionHeader(AppLocalizations.of(context)!.evidenceAndAttachments),
                const SizedBox(height: 16),

                // Attachment Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildAttachmentButton(
                        icon: Icons.add_a_photo,
                        label: AppLocalizations.of(context)!.addPhoto,
                        onTap: _pickImage,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAttachmentButton(
                        icon: Icons.videocam,
                        label: AppLocalizations.of(context)!.addVideo,
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
                          AppLocalizations.of(context)!.confirmAccuracy,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.submitComplaint,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send, size: 18),
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

class _AudioBar extends StatelessWidget {
  final double height;
  const _AudioBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withOpacity(0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
