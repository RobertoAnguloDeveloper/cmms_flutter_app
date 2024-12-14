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
    return Transform.translate(
      offset: const Offset(0, -300), // Cambiado de -250 a -300 para subir todo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Transform.translate(
            offset: const Offset(0, -100),
            child: Center(
              child: Image.asset(
                'assets/logo_item.png',
                height: 300.0,
                width: 300.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Color(0xFF295075),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: 340.0,
                  child: FormBuilderTextField(
                    name: 'username',
                    controller: usernameController,
                    focusNode: usernameFocus,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: "Username",
                      errorText: usernameError,
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: kIsWeb
                          ? Color.fromARGB(255, 222, 242, 255)
                          : Colors.white,
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
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                    ),
                    onChanged: onUsernameChanged,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 340.0,
                  child: FormBuilderTextField(
                    name: 'password',
                    controller: passwordController,
                    focusNode: passwordFocus,
                    enabled: !isLoading,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      errorText: passwordError,
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: kIsWeb
                          ? const Color.fromARGB(255, 222, 242, 255)
                          : Colors.white,
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
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: onTogglePasswordVisibility,
                      ),
                    ),
                    onChanged: onPasswordChanged,
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFF295075),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(Icons.login,
                              size: 24.0, color: Colors.white),
                        const SizedBox(width: 8.0),
                        Text(
                          isLoading ? "Logging in..." : "Login",
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
