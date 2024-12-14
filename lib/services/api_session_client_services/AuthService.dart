import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'SessionManager.dart';

class AuthService {
  static const String baseUrl = kIsWeb
      // ? "http://3.129.92.139" // URL WEB
      // : "http://3.129.92.139"; // URL ANDROID
      ? "http://localhost:5000" // URL WEB
      //? "" // URL WEB
      : "http://10.0.2.2:5000"; // URL ANDROID

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      String? token = await SessionManager.getToken();
      print('Token retrieved: ${token != null}');

      if (token == null) {
        return {}; // Return empty map instead of throwing exception
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw permissions data: ${data['permissions']}');
        return data;
      } else {
        return {}; // Return empty map for any error status
      }
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return {}; // Return empty map for any error
    }
  }
}