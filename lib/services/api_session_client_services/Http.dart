import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart' show kIsWeb;

class Http {
  //ENDPOINT IP
  final String baseUrl = kIsWeb
      //? "http://3.129.92.139" // URL WEB
      //: "http://3.129.92.139"; // URL ANDROID
      ? "http://localhost:5000" // URL WEB
      //? "" // URL WEB
      : "http://10.0.2.2:5000"; // URL ANDROID

  Future<http.Response> login(String path, dynamic data) async {
    final url = Uri.parse('$baseUrl$path');
    final body = convert.jsonEncode(data);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> get(String path, String? token) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String path, dynamic data, String? token) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = convert.jsonEncode(data);
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(String path, dynamic data, String? token) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = convert.jsonEncode(data);
    return await http.put(url, headers: headers, body: body);
  }

  Future<http.Response> delete(String path, String? token) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return await http.delete(url, headers: headers);
  }
}
