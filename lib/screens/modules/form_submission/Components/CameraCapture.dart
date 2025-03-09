// lib/screens/modules/form_submission/Components/CameraCapture.dart

/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCapture extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraCapture({
    Key? key,
    required this.onImageCaptured,
  }) : super(key: key);

  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Request camera permission first
      final PermissionStatus cameraPermission = await Permission.camera.request();

      if (cameraPermission != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null && mounted) {
        // Create a File object from the XFile
        final File imageFile = File(photo.path);

        // Pass the captured image to the parent widget via callback
        widget.onImageCaptured(imageFile);

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Camera error: $e');

      if (mounted) {
        // More detailed error message
        String errorMessage = 'Error taking photo';

        if (e.toString().contains('channel-error')) {
          errorMessage = 'Camera connection failed. Please try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Camera permission denied. Please enable camera access in settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _takePhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: _isProcessing
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.camera_alt, color: Colors.white),
      label: Text(
        _isProcessing ? 'Processing...' : 'Take Photo',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/file_utils.dart';
import 'package:path/path.dart' as path;

class CameraCapture extends StatefulWidget {
  final Function(File) onImageCaptured;
  final String? namePrefix;  // Optional prefix for photo name

  const CameraCapture({
    Key? key,
    required this.onImageCaptured,
    this.namePrefix,
  }) : super(key: key);

  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Request camera permission first
      final PermissionStatus cameraPermission = await Permission.camera.request();

      if (cameraPermission != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null && mounted) {
        // Create a File object from the XFile
        final File originalFile = File(photo.path);

        // Rename the image file to a shorter name
        final File renamedFile = await FileUtils.createRenamedImageFile(originalFile);

        // Pass the captured image to the parent widget via callback
        widget.onImageCaptured(renamedFile);

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo captured: ${path.basename(renamedFile.path)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Camera error: $e');

      if (mounted) {
        // More detailed error message
        String errorMessage = 'Error taking photo';

        if (e.toString().contains('channel-error')) {
          errorMessage = 'Camera connection failed. Please try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Camera permission denied. Please enable camera access in settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the code remains the same
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _takePhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: _isProcessing
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.camera_alt, color: Colors.white),
      label: Text(
        _isProcessing ? 'Processing...' : 'Take Photo',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}