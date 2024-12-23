import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../gui/theme/env_theme_provider.dart';
import '../../models/user.dart';
import '../../configs/api_config.dart';
import '../../gui/screens/auth/login_screen.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Enum to represent different authentication states
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  error
}

/// Provider class to manage authentication state throughout the app
class AuthProvider with ChangeNotifier {
  // Services
  late final ApiClient _apiClient;
  late final AuthService _authService;
  final GlobalKey<NavigatorState> navigatorKey;
  BuildContext? _context;

  // State variables
  AuthState _authState = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Constructor
  AuthProvider({required this.navigatorKey}) {
    _apiClient = ApiClient(
      baseUrl: ApiConfig.baseUrl,
      onTokenExpired: handleTokenExpiration,
    );
    _authService = AuthService(_apiClient);
    _initializeAuth();
  }

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      await checkAuthStatus();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
  }

  /// Handle token expiration
  void handleTokenExpiration() {
    _setUnauthenticated();

    // Navigate to login screen
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      final isValid = await _apiClient.isAuthenticated();

      if (isValid) {
        try {
          _currentUser = await _authService.getCurrentUser();
          _setAuthenticated();
        } catch (e) {
          print('Error getting current user: $e');
          await _handleAuthenticationFailure();
        }
      } else {
        await _handleAuthenticationFailure();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      await _handleAuthenticationFailure();
      _setError('Failed to check authentication status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Handle login process
  Future<bool> login(String username, String password) async {
    if (_isLoading) return false;

    try {
      _setLoading(true);
      _clearError();

      // Attempt login
      await _authService.login(username, password);

      // Get user details
      _currentUser = await _authService.getCurrentUser();
      _setAuthenticated();

      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Handle logout process
  Future<void> logout() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      await _apiClient.clearToken();
      await _handleAuthenticationFailure();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (!isAuthenticated || _isLoading) return;

    try {
      _setLoading(true);
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Handle failed authentication
  Future<void> _handleAuthenticationFailure() async {
    await _apiClient.clearToken();
    _currentUser = null;
    _setUnauthenticated();
  }

  /// State management helpers
  void _setAuthenticated() {
    _authState = AuthState.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _authState = AuthState.unauthenticated;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _authState = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user data
  Future<bool> updateUserData({
    String? firstName,
    String? lastName,
    String? email,
    String? contactNumber,
  }) async {
    if (!isAuthenticated || _currentUser == null) return false;

    try {
      _setLoading(true);

      final updatedUser = await _authService.updateCurrentUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        contactNumber: contactNumber,
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update user data: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password request
  Future<bool> requestPasswordReset(String email) async {
    try {
      _setLoading(true);
      await _authService.requestPasswordReset(email);
      return true;
    } catch (e) {
      _setError('Failed to request password reset: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check permissions
  bool hasPermission(String permission) {
    return _currentUser?.role?.permissions
        ?.any((p) => p.name == permission) ?? false;
  }

  /// Check if user is admin
  bool get isAdmin => _currentUser?.role?.isSuperUser ?? false;

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}