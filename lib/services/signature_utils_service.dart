// lib/services/signature_utils_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SignatureUtilsService {
  /// Saves a signature to a file and returns the file path
  static Future<File?> saveSignature(GlobalKey key, String fileName) async {
    try {
      // Find the boundary from the key
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Unable to find boundary from key');
        return null;
      }

      // Capture the image with a higher quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to bytes
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('Failed to get byteData from image');
        return null;
      }

      // Get temporary directory to store the signature
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      debugPrint('Signature saved to: $filePath');
      return file;
    } catch (e) {
      debugPrint('Error saving signature: $e');
      return null;
    }
  }

  /// Checks if a signature file exists
  static Future<bool> signatureExists(String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking signature existence: $e');
      return false;
    }
  }

  /// Gets the path to an existing signature file or null if it doesn't exist
  static Future<String?> getSignaturePath(String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting signature path: $e');
      return null;
    }
  }

  /// Deletes a signature file
  static Future<bool> deleteSignature(String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting signature: $e');
      return false;
    }
  }

  /// Generate a unique filename for a signature based on timestamp
  static String generateSignatureFileName() {
    return 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
  }
}