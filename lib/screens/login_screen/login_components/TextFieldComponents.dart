import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode usernameFocus;
  final FocusNode passwordFocus;
  final bool isLoading;
  final bool obscurePassword;
  final String? usernameError;
  final String? passwordError;
  final void Function(String?)? onUsernameChanged;
  final void Function(String?)? onPasswordChanged;
  final VoidCallback onLoginPressed;
  final VoidCallback onTogglePasswordVisibility;

  const LoginFields({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.isLoading,
    required this.obscurePassword,
    required this.usernameError,
    required this.passwordError,
    this.onUsernameChanged,
    this.onPasswordChanged,
    required this.onLoginPressed,
    required this.onTogglePasswordVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isMobile = screenSize.width < 600;
    final isSmallHeight = screenSize.height < 600;
    final isWebPortrait = kIsWeb && !isLandscape;

    // Ajustamos dimensiones basadas en el contexto
    final logoSize = screenSize.width *
        (kIsWeb
            ? (isWebPortrait
                ? (isMobile
                    ? 0.45
                    : 0.3) // En web portrait: más grande si es móvil
                : 0.15) // Web landscape se mantiene igual
            : (isLandscape ? 0.23 : 0.37) // No web se mantiene como estaba
        );

    final formWidth = screenSize.width *
        (isMobile && !isLandscape
            ? 0.95 // Más ancho para móvil en portrait
            : (isMobile ? 0.85 : 0.4) // Mantiene los otros tamaños igual
        );

    // Ajustamos espaciado vertical
    final double topPadding = isWebPortrait
        ? screenSize.height * 0.15 // Más espacio superior en web portrait
        : isLandscape
            ? 10
            : (isSmallHeight
                ? screenSize.height * 0.03
                : screenSize.height * 0.05);

    final double spaceBetweenElements = isWebPortrait
        ? 25 // Más espacio entre elementos en web portrait
        : isLandscape || isSmallHeight
            ? 8
            : 15;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo_item.png',
            height: logoSize,
            width: logoSize,
            fit: BoxFit.contain,
          ),
          SizedBox(height: spaceBetweenElements * 0),
          Text(
            "Log in",
            style: TextStyle(
              fontSize: isWebPortrait
                  ? 28.0
                  : // Texto más grande en web portrait
                  (isLandscape || isSmallHeight
                      ? 18.0
                      : (isMobile ? 20.0 : 24.0)),
              color: const Color(0xFF295075),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spaceBetweenElements),
          Container(
            width: formWidth,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 10 : 20,
              vertical: isLandscape ? 5 : 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  name: 'username',
                  controller: usernameController,
                  focusNode: usernameFocus,
                  label: "Username",
                  icon: Icons.person,
                  error: usernameError,
                  onChange: onUsernameChanged,
                  isLandscape: isLandscape,
                  isWebPortrait: isWebPortrait,
                ),
                SizedBox(height: spaceBetweenElements),
                _buildTextField(
                  name: 'password',
                  controller: passwordController,
                  focusNode: passwordFocus,
                  label: "Password",
                  icon: Icons.lock,
                  error: passwordError,
                  isPassword: true,
                  onChange: onPasswordChanged,
                  isLandscape: isLandscape,
                  isWebPortrait: isWebPortrait,
                ),
                SizedBox(height: spaceBetweenElements * 1.2),
                SizedBox(
                  width: formWidth * (isLandscape ? 0.5 : 0.7),
                  height: isWebPortrait
                      ? 50
                      : // Botón más alto en web portrait
                      (isLandscape || isSmallHeight ? 40 : 45),
                  child: _buildLoginButton(
                    isLandscape: isLandscape,
                    isWebPortrait: isWebPortrait,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String name,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? error,
    bool isPassword = false,
    void Function(String?)? onChange,
    bool isLandscape = false,
    bool isWebPortrait = false,
  }) {
    return FormBuilderTextField(
      name: name,
      controller: controller,
      focusNode: focusNode,
      enabled: !isLoading,
      obscureText: isPassword && obscurePassword,
      style: TextStyle(fontSize: isWebPortrait ? 18 : (isLandscape ? 14 : 16)),
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        labelStyle: TextStyle(
          fontSize: isWebPortrait ? 18 : (isLandscape ? 14 : 16),
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: kIsWeb
            ? const Color.fromARGB(255, 222, 242, 255)
            : Color.fromARGB(255, 222, 242, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xAAE0E0E0),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
          size: isWebPortrait ? 28 : (isLandscape ? 20 : 24),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: isWebPortrait ? 28 : (isLandscape ? 20 : 24),
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          vertical: isWebPortrait ? 16 : (isLandscape ? 8 : 12),
          horizontal: isWebPortrait ? 16 : (isLandscape ? 8 : 12),
        ),
      ),
      onChanged: onChange,
    );
  }

  Widget _buildLoginButton(
      {bool isLandscape = false, bool isWebPortrait = false}) {
    return ElevatedButton(
      onPressed: isLoading ? null : onLoginPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFF295075),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isWebPortrait ? 16 : (isLandscape ? 8 : 12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            Container(
              width: isWebPortrait ? 28 : (isLandscape ? 20 : 24),
              height: isWebPortrait ? 28 : (isLandscape ? 20 : 24),
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            Icon(Icons.login,
                size: isWebPortrait ? 28 : (isLandscape ? 20 : 24),
                color: Colors.white),
          const SizedBox(width: 8.0),
          Text(
            isLoading ? "Logging in..." : "Login",
            style: TextStyle(
              fontSize: isWebPortrait ? 18 : (isLandscape ? 14 : 16),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
