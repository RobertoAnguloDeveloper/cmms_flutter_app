import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../services/api_services/api_client.dart';
import '../../../configs/api_config.dart';
import '../../components/api_test_button.dart';
import '../../components/json_viewer.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  late final ApiClient _apiClient;
  Map<String, dynamic>? _result;
  String? _error;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Username and password are required';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _result = null;
        _error = null;
      });

      final response = await _apiClient.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        _result = response is Map ? Map<String, dynamic>.from(response) : {'data': response};
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testEndpoint(Future<Response> Function() apiCall) async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await apiCall();
      setState(() {
        if (response.data is Map) {
          _result = Map<String, dynamic>.from(response.data);
        } else if (response.data is List) {
          _result = {'items': response.data};
        } else {
          _result = {'result': response.data};
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left panel with scrollable buttons
          SizedBox(
            width: 300,
            child: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'API Test Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Base URL:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ApiConfig.baseUrl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          key: const Key('username_field'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          obscureText: true,
                          key: const Key('password_field'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                  ApiTestButton(
                    title: 'Get Current User',
                    onPressed: () => _testEndpoint(
                          () => _apiClient.get('/api/users/current'),
                    ),
                  ),
                  ApiTestButton(
                    title: 'List Environments',
                    onPressed: () => _testEndpoint(
                          () => _apiClient.get('/api/environments'),
                    ),
                  ),
                  ApiTestButton(
                    title: 'List Forms',
                    onPressed: () => _testEndpoint(
                          () => _apiClient.get('/api/forms'),
                    ),
                  ),
                  ApiTestButton(
                    title: 'List Questions',
                    onPressed: () => _testEndpoint(
                          () => _apiClient.get('/api/questions'),
                    ),
                  ),
                  ApiTestButton(
                    title: 'List Roles',
                    onPressed: () => _testEndpoint(
                          () => _apiClient.get('/api/roles'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right panel with results
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'API Response',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (_result != null)
                      Expanded(
                        child: JsonViewer(_result!),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}