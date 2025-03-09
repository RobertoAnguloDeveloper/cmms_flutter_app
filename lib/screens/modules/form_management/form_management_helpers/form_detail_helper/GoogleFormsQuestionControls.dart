import 'package:flutter/material.dart';

class GoogleFormsQuestionControls extends StatelessWidget {
  final bool isRequired;
  final Function(bool) onRequiredChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool showDivider;

  const GoogleFormsQuestionControls({
    Key? key,
    required this.isRequired,
    required this.onRequiredChanged,
    required this.onDuplicate,
    required this.onDelete,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Required toggle with label
              Row(
                children: [
                  Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isRequired,
                      onChanged: onRequiredChanged,
                      activeColor: const Color(0xFF673AB7), // Google Forms purple
                      activeTrackColor: const Color(0xFFD1C4E9),
                    ),
                  ),
                ],
              ),

              // Right side - Action icons
              Row(
                children: [
                  // Vertical divider
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  // Delete icon
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey[700], size: 20),
                    splashRadius: 20,
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}