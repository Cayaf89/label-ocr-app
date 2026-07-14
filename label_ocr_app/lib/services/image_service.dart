import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for saving and managing captured images.
///
/// Handles file operations in the app's private data directory,
/// specifically within a `captures/` subdirectory.
class ImageService {
  static const String capturesDirName = 'captures';

  /// Get the app's documents directory.
  Future<Directory> _getAppDataDir() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(baseDir.path, capturesDirName));
  }

  /// Ensure the captures directory exists and return it.
  Future<Directory> ensureCapturesDir() async {
    final dir = await _getAppDataDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save a captured image to the captures directory with timestamp naming.
  ///
  /// The file is named `capture_{timestamp}.jpg` where [timestamp] is derived
  /// from [DateTime.now()] with colons and dots removed for filesystem safety.
  ///
  /// Returns the absolute path of the saved file.
  Future<String> saveCapture(File imageFile) async {
    final Directory capturesDir = await ensureCapturesDir();
    final DateTime now = DateTime.now();
    final String timestamp = now.toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '',
    );
    final String fileName = 'capture_$timestamp.jpg';
    final String newPath = path.join(capturesDir.path, fileName);

    // Copy the file to our captures directory
    await imageFile.copy(newPath);
    return newPath;
  }

  /// Save an XFile (from camera) to the captures directory.
  ///
  /// Extracts the [path] from the [xFile] object and delegates to [saveCapture].
  Future<String> saveCaptureFromXFile(dynamic xFile) async {
    final String filePath = _extractPath(xFile);
    return saveCapture(File(filePath));
  }

  /// Delete a captured image file.
  ///
  /// Silently does nothing if the file doesn't exist.
  Future<void> deleteCapture(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently ignore deletion errors for non-existent files
    }
  }

  /// Check if an image file exists on disk.
  Future<bool> captureExists(String imagePath) async {
    return File(imagePath).exists();
  }

  /// Get the total size of all captured images in bytes.
  Future<int> getTotalCaptureSize() async {
    final Directory capturesDir = await ensureCapturesDir();
    if (!await capturesDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in capturesDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// Clear all captured images from the captures directory.
  Future<void> clearCaptures() async {
    final Directory capturesDir = await ensureCapturesDir();
    if (!await capturesDir.exists()) return;

    await for (final entity in capturesDir.list()) {
      if (entity is File) {
        try {
          await entity.delete();
        } catch (_) {
          // Silently ignore individual file deletion errors
        }
      }
    }
  }

  /// Extract the file path from an XFile-like object.
  ///
  /// Handles both [XFile] objects (with a .path property) and raw strings.
  String _extractPath(dynamic xFile) {
    if (xFile is File) return xFile.path;
    if (xFile != null && xFile.toString().contains('XFile')) {
      // XFile-like object: try to get the path property via reflection
      final dynamic pathProp = xFile.path;
      if (pathProp is String) return pathProp;
    }
    if (xFile is String) return xFile;
    throw ArgumentError('Unsupported file type: ${xFile.runtimeType}');
  }

  /// Get the number of captured images.
  Future<int> getCaptureCount() async {
    final Directory capturesDir = await ensureCapturesDir();
    if (!await capturesDir.exists()) return 0;

    int count = 0;
    await for (final entity in capturesDir.list()) {
      if (entity is File) {
        count++;
      }
    }
    return count;
  }
}
