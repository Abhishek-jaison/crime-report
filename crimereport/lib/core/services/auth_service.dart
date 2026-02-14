import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String aadhaarNumber,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'aadhaar_number': aadhaarNumber,
    });

    print('API Request: POST $url');
    print('API Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode({'email': email, 'password': password});

    print('API Request: POST $url');
    print('API Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-otp');
    final body = jsonEncode({'email': email});

    print('API Request: POST $url');
    print('API Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    final body = jsonEncode({'email': email, 'otp': otp});

    print('API Request: POST $url');
    print('API Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': data['message'] ?? 'Success',
          'data': data, // Return user data or token here if available
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
