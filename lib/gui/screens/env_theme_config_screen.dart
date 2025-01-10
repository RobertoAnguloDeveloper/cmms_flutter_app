// 📂 lib/gui/screens/env_theme_config_screen.dart

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../services/api_services/auth_provider.dart';
import '../../services/api_services/api_client.dart';
import '../../services/api_services/cmms_config_provider.dart';
import '../../services/api_services/environment_service.dart';
import '../../services/config/environment_theme_config_manager.dart';
import '../../models/environment.dart';
import '../../services/platform/logo_loader_service.dart';
import '../components/custom_button.dart';
import '../components/color_picker_dialog.dart';
import '../components/screen_scaffold.dart';
import '../components/info_card.dart';
import '../components/theme_preview.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';
import '../../constants/gui_constants/theme_constants.dart';
import '../../configs/api_config.dart';
import 'logo_crop_screen.dart';
import '../../models/logo_transform.dart';

class EnvThemeConfigScreen extends StatefulWidget {
  const EnvThemeConfigScreen({super.key});

  @override
  State<EnvThemeConfigScreen> createState() => _EnvThemeConfigScreenState();
}

class _EnvThemeConfigScreenState extends State<EnvThemeConfigScreen> {
  late final ApiClient _apiClient;
  late final EnvironmentService _environmentService;
  late final EnvironmentThemeConfigManager _configManager;
  late final LogoLoaderService _logoLoader;
  LogoTransformData? _logoTransform;

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
    _logoLoader = LogoLoaderService(_apiClient);
    _loadEnvironments();
  }

  void _showLogoCropScreen() {
    if (_logoPreview == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LogoCropScreen(
          filename: _selectedLogoPath!,
          logoBytes: _logoPreview!,
          initialTransform: _logoTransform,
          onSave: (transformData) {
            setState(() {
              _logoTransform = transformData;
            });
            // Save the transform data to your configuration
            if (_selectedEnvironment != null) {
              _saveLogoTransform(transformData);
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveLogoTransform(LogoTransformData transform) async {
    try {
      // Get current theme settings
      final themeSettings =
          await _configManager.getEnvironmentTheme(_selectedEnvironment!.id);
      if (themeSettings != null) {
        // Update with transform data
        themeSettings['logo_transform'] = transform.toJson();

        // Save updated settings
        await _configManager.saveEnvironmentConfig(
          environment: _selectedEnvironment!,
          themeSettings: {
            // Direct object, no extra nesting
            'primary_color': _colorToHex(_primaryColor),
            'secondary_color': _colorToHex(_secondaryColor),
            'background_color': _colorToHex(_backgroundColor),
            'text_color': _colorToHex(_textColor),
            'font_family': _fontFamily,
            'font_size_scale': _fontSizeScale,
            'logo_file': _selectedLogoPath,
            'logo_transform': _logoTransform?.toJson(),
          },
        );
      }
    } catch (e) {
      print('Error saving logo transform: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving logo adjustments: $e')),
        );
      }
    }
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
      final themeSettings =
          await _configManager.getEnvironmentTheme(environment.id);

      if (themeSettings != null) {
        setState(() {
          _primaryColor = _colorFromHex(themeSettings['primary_color']);
          _secondaryColor = _colorFromHex(themeSettings['secondary_color']);
          _backgroundColor = _colorFromHex(themeSettings['background_color']);
          _textColor = _colorFromHex(themeSettings['text_color']);
          _fontFamily = themeSettings['font_family'];
          _fontSizeScale = themeSettings['font_size_scale'];
          _selectedLogoPath = themeSettings['logo_file'];

          if (themeSettings['logo_transform'] != null) {
            _logoTransform = LogoTransformData.fromJson(
                themeSettings['logo_transform'] as Map<String, dynamic>);
          } else {
            _logoTransform = null;
          }
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

      setState(() => _isLoading = true);

      // Use LogoLoaderService instead of CmmsConfigProvider
      final bytes = await _logoLoader.loadLogo(_selectedLogoPath!);

      if (mounted) {
        setState(() {
          _logoPreview = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading logo preview: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
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
    if (_selectedEnvironment == null) return;

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
        'logo_transform': _logoTransform?.toJson(),
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
      setState(() => _error = 'Failed to save configuration: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLogoSection() {
    final double containerSize = 175;
    final double cropScreenSize = 200.0;
    final double scaleRatio = containerSize / cropScreenSize;

    return InfoCard(
      title: 'Environment Logo',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: GestureDetector(
              onTap: _logoPreview != null ? _showLogoCropScreen : null,
              child: Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _logoTransform?.backgroundColor ?? Colors.white,
                  ),
                  child: _logoPreview != null
                      ? Stack(
                          children: [
                            SizedBox.expand(
                              child: OverflowBox(
                                maxWidth: cropScreenSize,
                                maxHeight: cropScreenSize,
                                child: Transform.scale(
                                  scale: scaleRatio *
                                      (_logoTransform?.scale ?? 1.0),
                                  child: Transform.translate(
                                    offset:
                                        _logoTransform?.position ?? Offset.zero,
                                    child: Image.memory(
                                      _logoPreview!,
                                      width: cropScreenSize,
                                      height: cropScreenSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isLoading)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'No logo selected',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Upload button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Upload button - sized to content
              SizedBox(
                height: 45, // Smaller fixed height
                child: CustomButton(
                  text: "Upload",
                  onPressed: _isLoading ? null : _pickAndUploadLogo,
                  icon: const Icon(Icons.cloud_upload,
                      size: 38, color: Colors.white), // Smaller icon
                  variant: ButtonVariant.upload,
                  size: ButtonSize.small,
                ),
              ),
              if (_selectedLogoPath != null) ...[
                const SizedBox(width: AppSpacing.sm),
                // Reload button - sized to content
                SizedBox(
                  height: 45, // Smaller fixed height
                  child: CustomButton(
                    text: "Reload",
                    onPressed: _isLoading ? null : () => _loadLogoPreview(),
                    icon: const Icon(Icons.refresh,
                        size: 38, color: Colors.white), // Smaller icon
                    variant: ButtonVariant.reload,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ],
          ),
          if (_selectedLogoPath != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Selected: $_selectedLogoPath'),
            const SizedBox(height: AppSpacing.sm),
            CustomButton(
              text: 'Remove Logo',
              onPressed: _isLoading
                  ? null
                  : () => setState(() {
                        _logoPreview = null;
                        _selectedLogoPath = null;
                        _logoTransform = null;
                      }),
              variant: ButtonVariant.danger,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
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
                      content: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
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
                          items:
                              ThemeConstants.availableFontFamilies.map((font) {
                            return DropdownMenuItem(
                              value: font,
                              child: Text(font,
                                  style: TextStyle(fontFamily: font)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _fontFamily = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Font Size Scale',
                            style: theme.textTheme.titleSmall),
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
