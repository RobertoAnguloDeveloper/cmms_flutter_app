// 📂 lib/gui/components/custom_input.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final String? errorText;
  final bool required;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffix;
  final Widget? prefix;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.label,
    this.placeholder,
    this.value,
    this.errorText,
    this.required = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffix,
    this.prefix,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Input Field
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}