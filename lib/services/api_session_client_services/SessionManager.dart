import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/user_management_models/User.dart';

class SessionManager {
  static const String _keyUserId = 'id';
  static const String _keyIdType = 'id_type';
  static const String _keyIdentification = 'identification';
  static const String _keyFirstName = 'firstName';
  static const String _keyLastName = 'lastName';
  static const String _keyEmail = 'email';
  static const String _keyRoleId = 'role_id';
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyToken = 'token';

  static const String _keyPdfHeaderOpacity = 'pdf_header_opacity';
  static const String _keyPdfHeaderSize = 'pdf_header_size';
  static const String _keyPdfHeaderAlignment = 'pdf_header_alignment';
  static const String _keyPdfSignaturesSize = 'pdf_signatures_size';
  static const String _keyPdfSignaturesAlignment = 'pdf_signatures_alignment';
  static const String _keyPdfHeaderImagePath = 'pdf_header_image_path';

  static Future<void> saveSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keyUserId, user.id);
    prefs.setString(_keyIdType, user.id_type);
    prefs.setString(_keyIdentification, user.identification);
    prefs.setString(_keyFirstName, user.firstName);
    prefs.setString(_keyLastName, user.lastName);
    prefs.setString(_keyEmail, user.email);
    prefs.setInt(_keyRoleId, user.role_id);
    prefs.setString(_keyUsername, user.username);
    prefs.setString(_keyPassword, user.password);
  }

  static Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyToken, token);
    print('Token saved in SessionManager: $token');
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_keyToken);
    print('Token retrieved from SessionManager: $token');
    return token;
  }

  static Future<Map<String, dynamic>?> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt(_keyUserId);
    String? id_type = prefs.getString(_keyIdType);
    String? identification = prefs.getString(_keyIdentification);
    String? firstName = prefs.getString(_keyFirstName);
    String? lastName = prefs.getString(_keyLastName);
    String? email = prefs.getString(_keyEmail);
    int? role = prefs.getInt(_keyRoleId);
    String? username = prefs.getString(_keyUsername);
    String? password = prefs.getString(_keyPassword);

    if (id != null && username != null && role != null) {
      return {
        'id': id,
        'id_type': id_type,
        'identification': identification,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'username': username,
        'password': password,
      };
    } else {
      return null;
    }
  }

  static Future<bool> isValidSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }

  // Updated to include header image path
  static Future<void> savePdfExportPreferences({
    required double headerOpacity,
    required double headerSize,
    required String headerAlignment,
    required double signaturesSize,
    required String signaturesAlignment,
    String? headerImagePath,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_keyPdfHeaderOpacity, headerOpacity);
    prefs.setDouble(_keyPdfHeaderSize, headerSize);
    prefs.setString(_keyPdfHeaderAlignment, headerAlignment);
    prefs.setDouble(_keyPdfSignaturesSize, signaturesSize);
    prefs.setString(_keyPdfSignaturesAlignment, signaturesAlignment);

    // Save header image path if provided
    if (headerImagePath != null) {
      // Save the original path
      prefs.setString(_keyPdfHeaderImagePath, headerImagePath);

      // Also copy the image to app documents directory for persistence
      await _saveHeaderImageCopy(headerImagePath);
    }
  }

  // Helper method to make a persistent copy of the header image
  static Future<void> _saveHeaderImageCopy(String originalPath) async {
    try {
      final File originalFile = File(originalPath);
      if (await originalFile.exists()) {
        final bytes = await originalFile.readAsBytes();

        // Get app documents directory for saving the copy
        final directory = await getApplicationDocumentsDirectory();
        final String filename = 'header_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String persistentPath = '${directory.path}/$filename';

        // Save the copy
        final File persistentFile = File(persistentPath);
        await persistentFile.writeAsBytes(bytes);

        // Update the stored path to point to our persistent copy
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(_keyPdfHeaderImagePath, persistentPath);

        print('Header image saved to persistent location: $persistentPath');
      }
    } catch (e) {
      print('Error saving header image copy: $e');
      // Continue anyway - original path will still be used
    }
  }

  // Updated to include header image path in returned preferences
  static Future<Map<String, dynamic>> getPdfExportPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? headerImagePath = prefs.getString(_keyPdfHeaderImagePath);

    // Verify the image file still exists
    if (headerImagePath != null) {
      File imageFile = File(headerImagePath);
      if (!await imageFile.exists()) {
        print('Saved image no longer exists at path: $headerImagePath');
        headerImagePath = null;
      }
    }

    return {
      'headerOpacity': prefs.getDouble(_keyPdfHeaderOpacity) ?? 100.0,
      'headerSize': prefs.getDouble(_keyPdfHeaderSize) ?? 20.0,
      'headerAlignment': prefs.getString(_keyPdfHeaderAlignment) ?? 'left',
      'signaturesSize': prefs.getDouble(_keyPdfSignaturesSize) ?? 100.0,
      'signaturesAlignment': prefs.getString(_keyPdfSignaturesAlignment) ?? 'horizontal',
      'headerImagePath': headerImagePath,
    };
  }

  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove only user session related keys
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyIdType);
    await prefs.remove(_keyIdentification);
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRoleId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyToken);

    // PDF preferences are not deleted, they remain intact
    print('Session cleared but PDF preferences retained');
  }
}