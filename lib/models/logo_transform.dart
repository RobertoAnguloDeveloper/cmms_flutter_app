// 📂 lib/models/logo_transform.dart

import 'package:flutter/material.dart';

/// Model class to handle logo transformation data
class LogoTransformData {
  final double scale;
  final Offset position;
  final Color? backgroundColor;

  const LogoTransformData({
    required this.scale,
    required this.position,
    this.backgroundColor,
  });

  /// Create from JSON map
  factory LogoTransformData.fromJson(Map<String, dynamic> json) {
    final position = json['position'] as Map<String, dynamic>;
    String? bgColor = json['background_color'] as String?;

    // Handle both int and double values for position
    final double xPos = position['x'] is int ?
    (position['x'] as int).toDouble() :
    position['x'] as double;

    final double yPos = position['y'] is int ?
    (position['y'] as int).toDouble() :
    position['y'] as double;

    // Handle scale value which might also come as int
    final double scaleValue = json['scale'] is int ?
    (json['scale'] as int).toDouble() :
    (json['scale'] as double?) ?? 1.0;

    return LogoTransformData(
      scale: scaleValue,
      position: Offset(xPos, yPos),
      backgroundColor: bgColor != null ?
      Color(int.parse('FF${bgColor.replaceFirst('#', '')}', radix: 16)) :
      null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
    'scale': scale,
    'position': {
      'x': position.dx,
      'y': position.dy,
    },
    if (backgroundColor != null)
      'background_color': '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
  };

  /// Create a copy with some properties changed
  LogoTransformData copyWith({
    double? scale,
    Offset? position,
    Color? backgroundColor,
  }) {
    return LogoTransformData(
      scale: scale ?? this.scale,
      position: position ?? this.position,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Create default transform data
  factory LogoTransformData.defaultTransform() {
    return const LogoTransformData(
      scale: 1.0,
      position: Offset.zero,
      backgroundColor: Colors.white,
    );
  }

  @override
  String toString() {
    return 'LogoTransformData(scale: $scale, position: $position, backgroundColor: $backgroundColor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogoTransformData &&
        other.scale == scale &&
        other.position == position &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode =>
      scale.hashCode ^ position.hashCode ^ backgroundColor.hashCode;
}