import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ComplaintService {
  // Use 10.0.2.2 for Android Emulator to access localhost of the host machine.
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> submitComplaint({
    required String title,
    required String description,
    required String crimeType,
    required String userEmail,
    File? image,
    File? video,
  }) async {
    final url = Uri.parse('$baseUrl/complaints/');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['crime_type'] = crimeType;
      request.fields['user_email'] = userEmail;

      // Add image
      if (image != null) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: path.basename(image.path),
        );
        request.files.add(multipartFile);
      }

      // Add video
      if (video != null) {
        var stream = http.ByteStream(video.openRead());
        var length = await video.length();
        var multipartFile = http.MultipartFile(
          'video',
          stream,
          length,
          filename: path.basename(video.path),
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'Complaint submitted successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'An error occurred',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: ${response.statusCode}',
      };
    }
  }
}
