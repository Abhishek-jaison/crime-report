import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class SOSService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> sendSOSAlert({
    required String lat,
    required String long,
    String? userEmail,
  }) async {
    final url = Uri.parse('$baseUrl/sos/');

    print('API Request: POST $url');
    print('API Body: {lat: $lat, long: $long, user_email: $userEmail}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lat': lat, 'long': long, 'user_email': userEmail}),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to send SOS alert: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error sending SOS: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
