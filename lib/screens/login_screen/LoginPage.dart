import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;

import '../../components/SnackBarUtil.dart';
import '../../models/Permission_set.dart';
import '../../services/api_model_services/LoginApiService.dart';
import '../../services/api_session_client_services/AuthService.dart';
import '../../services/api_session_client_services/SessionManager.dart';
import '../modules/home/HomePage.dart';
import 'login_components/TextFieldComponents.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _usernameError = _validateUsername(_usernameController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    try {
      if (_usernameError == null && _passwordError == null) {
        final userApiService = LoginApiService();

        final userCredentials = {
          'username': _usernameController.text,
          'password': _passwordController.text,
        };

        final loginResponse = await userApiService.login(userCredentials);

        if (!mounted) return;

        if (loginResponse['status'] == 200) {
          final token = loginResponse['access_token'];
          if (token != null && token.isNotEmpty) {
            await SessionManager.setToken(token);

            final userData = await AuthService.getCurrentUser();
            print('Raw permissions data from API: ${userData['permissions']}');

            final permissionSet =
                PermissionSet.fromJson(userData['permissions'] as List);
            print(
                'Created permission set with permissions: ${permissionSet.permissions}');

            if (!mounted) return;

            showToast(context, 'Login successful');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  sessionData: userData,
                  permissionSet: permissionSet,
                ),
              ),
            );
          } else {
            _showErrorDialog('Error obtaining authentication token');
          }
        } else {
          _showErrorDialog('The credentials are not correct');
        }
      }
    } catch (e) {
      print('Error during login: $e');
      if (!mounted) return;
      _showErrorDialog('An error occurred during login');
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Color.fromARGB(255, 252, 70, 57), width: 4.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 40.0,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF295075),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneOnWeb = kIsWeb &&
        (ui.window.physicalSize.width / ui.window.devicePixelRatio) < 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWebLandscape = kIsWeb && isLandscape;
    final isMobile = !kIsWeb;
    final isWebFullScreen = kIsWeb && !isPhoneOnWeb;

    final scaleFactor = isWebLandscape ? 0.7 : 1.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo web y móvil
          if (kIsWeb)
            Positioned.fill(
              child: Image.asset(
                'assets/web_login_background.png',
                fit: BoxFit.cover,
              ),
            ),
          if (!kIsWeb)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFD9F0F6),
              ),
            ),
          // Imagen superior para móvil
          if (isMobile)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.45, // Reducido para más espacio arriba
                child: Image.asset(
                  'assets/login_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Posicionamiento del formulario
          Positioned(
            left: 0,
            right: 0,
            top: kIsWeb
                ? (isPhoneOnWeb // Caso: Web móvil
                    ? (isLandscape
                        ? MediaQuery.of(context).size.height * 0.0
                        : MediaQuery.of(context).size.height * 0.25)
                    : MediaQuery.of(context).size.height * 0.12)
                : (isLandscape
                    ? MediaQuery.of(context).size.height *
                        0.5 // Más abajo en landscape móvil
                    : MediaQuery.of(context).size.height *
                        0.4), // Normal en portrait móvil
            child: Transform.scale(
              scale: scaleFactor,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWebFullScreen
                      ? 300.0 // Márgenes amplios en escritorio
                      : 20.0, // Márgenes estándar en móvil y web móvil
                ),
                child: FormBuilder(
                  key: _formKey,
                  child: LoginFields(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    usernameFocus: _usernameFocus,
                    passwordFocus: _passwordFocus,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    usernameError: _usernameError,
                    passwordError: _passwordError,
                    onUsernameChanged: (value) {
                      setState(() {
                        _usernameError = null;
                      });
                    },
                    onPasswordChanged: (value) {
                      setState(() {
                        _passwordError = null;
                      });
                    },
                    onLoginPressed: _handleLogin,
                    onTogglePasswordVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  SnackBarUtil.showCustomSnackBar(
    context: context,
    message: message,
    duration: const Duration(seconds: 1),
  );
}
