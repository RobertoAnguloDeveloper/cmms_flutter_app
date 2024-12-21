// 📂 lib/services/app_services/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../api_services/api_client.dart';
import '../api_services/auth_service.dart';
import '../../models/user.dart';
import '../../configs/api_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
  late final AuthService _authService;

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  AuthProvider() {
    _authService = AuthService(_apiClient);
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  Future<void> checkAuthStatus() async {
    try {
      final token = await _apiClient.getToken();
      if (token != null) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.login(username, password);
      _currentUser = await _authService.getCurrentUser();
      _isAuthenticated = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.clearToken();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}