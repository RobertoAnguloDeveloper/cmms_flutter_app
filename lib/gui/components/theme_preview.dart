// 📂 lib/gui/components/theme_preview.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

class ThemePreview extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double fontScale;

  const ThemePreview({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Theme Preview',
              style: TextStyle(
                color: _getContrastColor(primaryColor),
                fontSize: 24 * fontScale,
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Example
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Title',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 20 * fontScale,
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'This is an example card showing how content will appear with the selected theme settings.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16 * fontScale,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: _getContrastColor(primaryColor),
                        ),
                        child: Text(
                          'Primary Button',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: _getContrastColor(secondaryColor),
                        ),
                        child: Text(
                          'Secondary Button',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Typography Examples
                  Text(
                    'Typography Example',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18 * fontScale,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This text demonstrates how regular content will look with the selected font family ($fontFamily) and text color.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16 * fontScale,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Smaller text example',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14 * fontScale,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}