import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';


class FileUtils {
  /// Creates a shorter, more manageable filename for images and returns the new file
  static Future<File> createRenamedImageFile(File originalFile) async {
    // Get the temporary directory to store the renamed image
    final directory = await getTemporaryDirectory();

    // Get the original extension
    final extension = path.extension(originalFile.path).toLowerCase();

    // Create a shorter filename with date format using "photo" as the prefix
    final formatter = DateFormat('ddMMyyyy_HHmmss');
    final timestamp = formatter.format(DateTime.now());
    final newFileName = 'photo_${timestamp}${extension}';

    // Define the new path
    final newPath = path.join(directory.path, newFileName);

    // Copy the original file to the new path
    return await originalFile.copy(newPath);
  }

  /// Gets a custom name for a photo with optional prefix
  static String getCustomPhotoName({String prefix = 'photo'}) {
    final formatter = DateFormat('ddMMyyyy_HHmmss');
    final timestamp = formatter.format(DateTime.now());
    return '${prefix}_$timestamp.jpg';
  }
}
