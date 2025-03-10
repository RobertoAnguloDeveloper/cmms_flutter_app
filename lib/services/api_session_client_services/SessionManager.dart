import 'package:shared_preferences/shared_preferences.dart';

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
    print('Token guardado en SessionManager: $token');
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_keyToken);
    print('Token recuperado de SessionManager: $token');
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

  static Future<void> savePdfExportPreferences({
    required double headerOpacity,
    required double headerSize,
    required String headerAlignment,
    required double signaturesSize,
    required String signaturesAlignment,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_keyPdfHeaderOpacity, headerOpacity);
    prefs.setDouble(_keyPdfHeaderSize, headerSize);
    prefs.setString(_keyPdfHeaderAlignment, headerAlignment);
    prefs.setDouble(_keyPdfSignaturesSize, signaturesSize);
    prefs.setString(_keyPdfSignaturesAlignment, signaturesAlignment);
  }

  static Future<Map<String, dynamic>> getPdfExportPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'headerOpacity': prefs.getDouble(_keyPdfHeaderOpacity) ?? 100.0,
      'headerSize': prefs.getDouble(_keyPdfHeaderSize) ?? 20.0,
      'headerAlignment': prefs.getString(_keyPdfHeaderAlignment) ?? 'left',
      'signaturesSize': prefs.getDouble(_keyPdfSignaturesSize) ?? 100.0,
      'signaturesAlignment': prefs.getString(_keyPdfSignaturesAlignment) ?? 'horizontal',
    };
  }

  // lib/services/api_session_client_services/SessionManager.dart

  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remover solo las claves relacionadas con la sesión del usuario
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

    // Las preferencias de PDF no se eliminan, permanecen intactas
    print('Session cleared but PDF preferences retained');
  }
}