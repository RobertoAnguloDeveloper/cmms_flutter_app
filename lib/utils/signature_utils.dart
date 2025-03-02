// lib/utils/signature_utils.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SignatureUtils {
  /// Converts a signature widget to a PNG file
  static Future<File?> exportSignature(GlobalKey key) async {
    try {
      // Find the boundary from the key
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Unable to find boundary from key');
        return null;
      }

      // Capture the image with a higher quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to bytes
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('Failed to get byteData from image');
        return null;
      }

      // Get temporary directory to store the signature
      final directory = await getTemporaryDirectory();
      final filename = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = path.join(directory.path, filename);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      print('Signature saved to: $filePath');
      return file;
    } catch (e) {
      print('Error exporting signature: $e');
      return null;
    }
  }
}