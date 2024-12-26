// 📂 lib/gui/screens/env_theme_config_screen.dart

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../services/api_services/auth_provider.dart';
import '../../services/api_services/api_client.dart';
import '../../services/api_services/environment_service.dart';
import '../../services/config/environment_theme_config_manager.dart';
import '../../models/environment.dart';
import '../components/custom_button.dart';
import '../components/color_picker_dialog.dart';
import '../components/screen_scaffold.dart';
import '../components/info_card.dart';
import '../components/theme_preview.dart';
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
  late final ApiClient _apiClient;
  late final EnvironmentService _environmentService;
  late final EnvironmentThemeConfigManager _configManager;


  bool _isLoading = false;
  String? _error;

  // Theme configuration state
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.green;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  String _fontFamily = ThemeConstants.defaultFontFamily;
  double _fontSizeScale = 1.0;
  Environment? _selectedEnvironment;
  List<Environment> _environments = [];

  // Logo state
  String? _selectedLogoPath;
  Uint8List? _logoPreview;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
    _environmentService = EnvironmentService(_apiClient);
    _configManager = EnvironmentThemeConfigManager(apiClient: _apiClient);
    _loadEnvironments();
  }

  Future<void> _loadEnvironments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _environments = await _environmentService.getAllEnvironments();

      if (_environments.isNotEmpty) {
        await _selectEnvironment(_environments.first);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectEnvironment(Environment environment) async {
    setState(() {
      _selectedEnvironment = environment;
      _isLoading = true;
      _error = null;
    });

    try {
      final themeSettings = await _configManager.getEnvironmentTheme(environment.id);

      if (themeSettings != null) {
        setState(() {
          _primaryColor = _colorFromHex(themeSettings['primary_color']);
          _secondaryColor = _colorFromHex(themeSettings['secondary_color']);
          _backgroundColor = _colorFromHex(themeSettings['background_color']);
          _textColor = _colorFromHex(themeSettings['text_color']);
          _fontFamily = themeSettings['font_family'];
          _fontSizeScale = themeSettings['font_size_scale'];
          _selectedLogoPath = themeSettings['logo_file'];

          // Load logo preview if path exists
          if (_selectedLogoPath != null) {
            _loadLogoPreview();
          } else {
            _logoPreview = null;
          }
        });
      } else {
        _resetToDefaults();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLogoPreview() async {
    try {
      if (_selectedLogoPath == null) return;

      final bytes = await _configManager.downloadConfig(_selectedLogoPath!);
      setState(() => _logoPreview = bytes);
    } catch (e) {
      print('Error loading logo preview: $e');
      setState(() => _logoPreview = null);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.image,
        sourceType: SourceType.photoLibrary,
      );
      final filePath = await FlutterFileDialog.pickFile(params: params);

      if (filePath == null) return;

      setState(() => _isLoading = true);

      // Read file bytes using dart:io
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      final fileName = filePath.split('/').last;
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      await _configManager.uploadConfig(multipartFile);

      setState(() {
        _logoPreview = bytes;
        _selectedLogoPath = fileName;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading logo: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _primaryColor = Colors.blue;
      _secondaryColor = Colors.green;
      _backgroundColor = Colors.white;
      _textColor = Colors.black;
      _fontFamily = ThemeConstants.defaultFontFamily;
      _fontSizeScale = 1.0;
      _logoPreview = null;
      _selectedLogoPath = null;
    });
  }

  Color _colorFromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    // Convert components to 8-bit values (0-255)
    final int r = (color.r * 255).round();
    final int g = (color.g * 255).round();
    final int b = (color.b * 255).round();
    final int a = (color.a * 255).round();

    // Pack into ARGB format
    final int colorInt = (a << 24) | (r << 16) | (g << 8) | b;

    // Convert to hex string, strip alpha channel, ensure uppercase
    return '#${colorInt.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Future<void> _handleSaveConfiguration() async {
    if (_selectedEnvironment == null) {
      setState(() {
        _error = 'Please select an environment first';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final themeSettings = {
        'primary_color': _colorToHex(_primaryColor),
        'secondary_color': _colorToHex(_secondaryColor),
        'background_color': _colorToHex(_backgroundColor),
        'text_color': _colorToHex(_textColor),
        'font_family': _fontFamily,
        'font_size_scale': _fontSizeScale,
        'logo_file': _selectedLogoPath,
      };

      await _configManager.saveEnvironmentConfig(
        environment: _selectedEnvironment!,
        themeSettings: themeSettings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme configuration saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save configuration: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLogoSection() {
    return InfoCard(
      title: 'Environment Logo',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Logo preview
          Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _logoPreview != null
                ? Image.memory(
              _logoPreview!,
              fit: BoxFit.contain,
            )
                : const Center(
              child: Text('No logo selected'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Upload button
          CustomButton(
            text: 'Upload Logo',
            onPressed: _pickAndUploadLogo,
            icon: const Icon(Icons.upload),
            variant: ButtonVariant.outline,
          ),
          if (_selectedLogoPath != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Selected: $_selectedLogoPath'),
            const SizedBox(height: AppSpacing.sm),
            CustomButton(
              text: 'Remove Logo',
              onPressed: () => setState(() {
                _logoPreview = null;
                _selectedLogoPath = null;
              }),
              variant: ButtonVariant.outline,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Only show this screen to admin users
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
              if (_error != null) ...[
          InfoCard(
          title: 'Error',
          content: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ],

    // Environment Selection
    InfoCard(
    title: 'Select Environment',
    content: DropdownButtonFormField<Environment>(
    value: _selectedEnvironment,
        decoration: const InputDecoration(
        labelText: 'Environment',
        border: OutlineInputBorder(),
    ),
    items: _environments.map((env) {
    return DropdownMenuItem(
    value: env,
    child: Text('${env.name} - ${env.description}'),
    );
    }).toList(),
    onChanged: (env) {
    if (env != null) _selectEnvironment(env);
    },
    ),
    ),
    const SizedBox(height: AppSpacing.lg),

    // Colors Section
    InfoCard(
    title: 'Colors',
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

    // Typography Section
    InfoCard(
    title: 'Typography',
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    labelText: 'Font Family',
    border: OutlineInputBorder(),
    ),
    value: _fontFamily,
    items: ThemeConstants.availableFontFamilies.map((font) {
    return DropdownMenuItem(
    value: font,
    child: Text(font, style: TextStyle(fontFamily: font)),
    );
    }).toList(),
    onChanged: (value) {
    if (value != null) {
    setState(() => _fontFamily = value);
    }
    },
    ),
    const SizedBox(height: AppSpacing.md),
    Text('Font Size Scale', style: theme.textTheme.titleSmall),
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
    const SizedBox(height: AppSpacing.lg),

    // Logo Section
    _buildLogoSection(),
    const SizedBox(height: AppSpacing.lg),

    // Theme Preview
    InfoCard(
    title: 'Live Preview',
    content: SizedBox(
    height: 400,
    child: ThemePreview(
    primaryColor: _primaryColor,
    secondaryColor: _secondaryColor,
    backgroundColor: _backgroundColor,
    textColor: _textColor,
    fontFamily: _fontFamily,
    fontScale: _fontSizeScale,
    ),
    ),
    ),
    const SizedBox(height: AppSpacing.xl),

    // Action Buttons
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    CustomButton(
    text: 'Reset to Defaults',
    onPressed: _resetToDefaults,
    variant: ButtonVariant.outline,
    ),
    const SizedBox(width: AppSpacing.md),
    CustomButton(
      text: 'Save Configuration',
      onPressed: _handleSaveConfiguration,
      variant: ButtonVariant.primary,
      isLoading: _isLoading,
    ),
    ],
    ),
              ],
          ),
        ),
    );
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
}