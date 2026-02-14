import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../config/api_config.dart';

class ComplaintService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> submitComplaint({
    required String title,
    required String description,
    required String crimeType,
    required String userEmail,
    File? image,
    File? video,
  }) async {
    final url = Uri.parse('$baseUrl/complaints/');

    print('API Request: POST $url');
    print(
      'API Body (Multipart Fields): {title: $title, description: $description, crime_type: $crimeType, user_email: $userEmail}',
    );

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

  Future<List<dynamic>> getMyComplaints(String userEmail) async {
    final url = Uri.parse(
      '$baseUrl/complaints/my-complaints?user_email=$userEmail',
    );

    print('API Request: GET $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final result = _handleResponse(response, isList: true);
      if (result['success'] == true && result['data'] != null) {
        return result['data'];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching complaints: $e");
      return [];
    }
  }

  Map<String, dynamic> _handleResponse(
    http.Response response, {
    bool isList = false,
  }) {
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (isList) {
          return {'success': true, 'data': data};
        }
        return {'success': true, 'message': 'Action successful', 'data': data};
      } else {
        return {
          'success': false,
          'message': (data is Map && data['detail'] != null)
              ? data['detail']
              : 'An error occurred',
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
