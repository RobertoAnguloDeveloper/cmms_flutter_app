// 📂 lib/services/cache/local_file_cache.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class FileMetadata {
  final String filename;
  final String modifiedAt;
  final int size;
  final String mimeType;

  FileMetadata({
    required this.filename,
    required this.modifiedAt,
    required this.size,
    required this.mimeType,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      filename: json['filename'],
      modifiedAt: json['modified_at'],
      size: json['size'],
      mimeType: json['mime_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'modified_at': modifiedAt,
    'size': size,
    'mime_type': mimeType,
  };
}

class LocalFileCache {
  static const String _metadataKey = 'file_cache_metadata';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> get _cacheDir async {
    final dir = await getApplicationCacheDirectory();
    final cacheDir = Directory('${dir.path}/file_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<Map<String, FileMetadata>> _loadMetadata() async {
    try {
      final metadataStr = await _secureStorage.read(key: _metadataKey);
      if (metadataStr == null) return {};

      final Map<String, dynamic> data = jsonDecode(metadataStr);
      return data.map((key, value) => MapEntry(
          key,
          FileMetadata.fromJson(value as Map<String, dynamic>)
      ));
    } catch (e) {
      print('Error loading cache metadata: $e');
      return {};
    }
  }

  Future<void> _saveMetadata(Map<String, FileMetadata> metadata) async {
    try {
      final metadataStr = jsonEncode(
          metadata.map((key, value) => MapEntry(key, value.toJson()))
      );
      await _secureStorage.write(key: _metadataKey, value: metadataStr);
    } catch (e) {
      print('Error saving cache metadata: $e');
    }
  }

  Future<File?> getCachedFile(String filename) async {
    try {
      final cacheDir = await _cacheDir;
      final file = File('$cacheDir/$filename');

      if (await file.exists()) {
        final fileStats = await file.stat();
        if (fileStats.size > 0) {
          // Verify file integrity
          try {
            final bytes = await file.readAsBytes();
            if (bytes.isNotEmpty) {
              return file;
            }
          } catch (e) {
            print('Error reading cached file: $e');
          }
        }

        // If we get here, file is invalid
        try {
          await file.delete();
        } catch (e) {
          print('Error deleting invalid cache file: $e');
        }
      }

      return null;
    } catch (e) {
      print('Error accessing cached file: $e');
      return null;
    }
  }

  Future<void> cacheFile(String filename, Uint8List bytes, FileMetadata metadataInfo) async {
    try {
      final cacheDir = await _cacheDir;
      final file = File('$cacheDir/$filename');

      // Ensure directory exists
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Write file atomically
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsBytes(bytes, flush: true);
      await tempFile.rename(file.path);

      // Save metadata
      final updatedMetadata = {
        ...await _loadMetadata(),
        filename: metadataInfo,
      };
      await _saveMetadata(updatedMetadata);

      print('File cached successfully: ${file.path}');
    } catch (e) {
      print('Error caching file: $e');
      rethrow;
    }
  }

  Future<bool> shouldUpdateFile(String filename, String modifiedAt, int size) async {
    try {
      final metadata = await _loadMetadata();
      if (!metadata.containsKey(filename)) return true;

      final cached = metadata[filename]!;
      return cached.modifiedAt != modifiedAt || cached.size != size;
    } catch (e) {
      print('Error checking file status: $e');
      return true;
    }
  }

  Future<void> clearCache() async {
    try {
      final cachePath = await _cacheDir;
      final cacheDir = Directory(cachePath);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      await _secureStorage.delete(key: _metadataKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}