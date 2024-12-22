// 📂 lib/gui/screens/env_theme_config_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/api_client.dart';
import '../../services/api_services/cmms_config_provider.dart';
import '../../services/api_services/environment_service.dart';
import '../../services/api_services/auth_provider.dart';
import '../../models/environment.dart';
import '../components/custom_button.dart';
import '../components/color_picker_dialog.dart';
import '../components/screen_scaffold.dart';
import '../components/info_card.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';
import '../../constants/gui_constants/theme_constants.dart';
import '../../configs/api_config.dart';

class EnvThemeConfigScreen extends StatefulWidget {
  const EnvThemeConfigScreen({super.key});

  @override
  State<EnvThemeConfigScreen> createState() => _EnvThemeConfigScreenState();
}

class _EnvThemeConfigScreenState extends State<EnvThemeConfigScreen> {
  final _environmentService = EnvironmentService(ApiClient(baseUrl: ApiConfig.baseUrl));
  List<Environment> _environments = [];
  Environment? _selectedEnvironment;
  bool _isLoading = false;

  // Theme configuration state
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.green;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  String _fontFamily = ThemeConstants.defaultFontFamily;
  double _fontSizeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadEnvironments();
  }

  Future<void> _loadEnvironments() async {
    try {
      setState(() => _isLoading = true);
      _environments = await _environmentService.getAllEnvironments();

      if (_environments.isNotEmpty) {
        setState(() {
          _selectedEnvironment = _environments.first;
        });
        await _loadConfigForEnvironment(_environments.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading environments: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadConfigForEnvironment(Environment environment) async {
    try {
      setState(() => _isLoading = true);

      final configProvider = Provider.of<CmmsConfigProvider>(context, listen: false);
      await configProvider.loadConfig('env_theme_${environment.id}.json');

      final config = configProvider.currentConfig;
      if (config != null && config.content.containsKey('parameters')) {
        final parameters = config.content['parameters'] as Map<String, dynamic>;
        if (parameters.containsKey('theme_settings')) {
          final themeSettings = parameters['theme_settings'] as Map<String, dynamic>;

          setState(() {
            _primaryColor = _colorFromHex(themeSettings['primary_color'] as String);
            _secondaryColor = _colorFromHex(themeSettings['secondary_color'] as String);
            _backgroundColor = _colorFromHex(themeSettings['background_color'] as String);
            _textColor = _colorFromHex(themeSettings['text_color'] as String);
            _fontFamily = themeSettings['font_family'] as String;
            _fontSizeScale = themeSettings['font_size_scale'] as double;
          });
        }
      }
    } catch (e) {
      print('Loading config error (using defaults): $e');
      // If config doesn't exist or there's an error, use defaults
      setState(() {
        _primaryColor = Colors.blue;
        _secondaryColor = Colors.green;
        _backgroundColor = Colors.white;
        _textColor = Colors.black;
        _fontFamily = ThemeConstants.defaultFontFamily;
        _fontSizeScale = 1.0;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _colorFromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _saveConfig() async {
    if (_selectedEnvironment == null) return;

    final configProvider = Provider.of<CmmsConfigProvider>(context, listen: false);
    final filename = 'env_theme_${_selectedEnvironment!.id}.json';

    try {
      // First try to delete any existing config
      try {
        await configProvider.deleteConfig();
      } catch (e) {
        print('Cleanup error (can be ignored): $e');
      }

      // Create new config
      await configProvider.saveConfig(
        filename: filename,
        content: {
          'name': 'Environment Theme Configuration',
          'description': 'Theme configuration for environment',
          'parameters': {
            'environment_id': _selectedEnvironment!.id,
            'environment_name': _selectedEnvironment!.name,
            'theme_settings': {
              'primary_color': _colorToHex(_primaryColor),
              'secondary_color': _colorToHex(_secondaryColor),
              'background_color': _colorToHex(_backgroundColor),
              'text_color': _colorToHex(_textColor),
              'font_family': _fontFamily,
              'font_size_scale': _fontSizeScale,
            }
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme configuration saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: $e')),
        );
      }
    }
  }

  Widget _buildColorPicker(
      String label,
      Color color,
      ValueChanged<Color> onColorChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTypography.body),
        ),
        const SizedBox(width: AppSpacing.md),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ColorPickerDialog(
                initialColor: color,
                onColorSelected: onColorChanged,
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Only show this screen to user with ID 1
    if (currentUser?.id != 1) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access this section.'),
        ),
      );
    }

    return ScreenScaffold(
      title: 'Environment Theme Configuration',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Environment Selection
            InfoCard(
              title: 'Select Environment',
              content: DropdownButtonFormField<Environment>(
                value: _selectedEnvironment,
                items: _environments.map((env) {
                  return DropdownMenuItem(
                    value: env,
                    child: Text(env.name),
                  );
                }).toList(),
                onChanged: (env) {
                  if (env != null) {
                    setState(() => _selectedEnvironment = env);
                    _loadConfigForEnvironment(env);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color Configuration
            InfoCard(
              title: 'Color Configuration',
              content: Column(
                children: [
                  _buildColorPicker(
                    'Primary Color',
                    _primaryColor,
                        (color) => setState(() => _primaryColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Secondary Color',
                    _secondaryColor,
                        (color) => setState(() => _secondaryColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Background Color',
                    _backgroundColor,
                        (color) => setState(() => _backgroundColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Text Color',
                    _textColor,
                        (color) => setState(() => _textColor = color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Typography Configuration
            InfoCard(
              title: 'Typography Configuration',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Font Family',
                    ),
                    value: _fontFamily,
                    items: ThemeConstants.availableFontFamilies.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(
                          font,
                          style: TextStyle(fontFamily: font),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fontFamily = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Font Size Scale', style: AppTypography.body),
                  Slider(
                    value: _fontSizeScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 12,
                    label: _fontSizeScale.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() => _fontSizeScale = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save Button
            Center(
              child: CustomButton(
                text: 'Save Configuration',
                onPressed: _saveConfig,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}