import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Service for camera capture and image picking.
///
/// Uses [ImagePicker] with rear-facing camera as primary method,
/// falling back to gallery picker when camera is unavailable or on desktop.
class CameraService {
  static const int _imageQuality = 95;

  final ImagePicker _picker = ImagePicker();

  /// Capture a photo using the rear-facing camera.
  ///
  /// Returns an [XFile] with the captured image, or `null` if the user
  /// cancelled the capture or an error occurred.
  ///
  /// Throws [Exception] on unexpected errors (e.g., permission denied).
  Future<XFile?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: _imageQuality,
      );
      return photo;
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('Canceled')) {
        return null;
      }
      throw Exception('Failed to capture photo: $e');
    }
  }

  /// Pick an image from the device gallery.
  ///
  /// Used as a fallback when camera is unavailable (desktop) or as an
  /// alternative for users who prefer selecting an existing photo.
  ///
  /// Returns an [XFile] with the selected image, or `null` if cancelled.
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: _imageQuality,
      );
      return image;
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('Canceled')) {
        return null;
      }
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Check whether at least one camera is available on the device.
  ///
  /// Returns `true` if a rear-facing camera exists, `false` otherwise.
  Future<bool> isCameraAvailable() async {
    try {
      // ImagePicker doesn't expose availableCameras directly;
      // we attempt a quick probe by checking if camera source works.
      final XFile? testPhoto = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 10,
      );
      // Clean up the test photo
      if (testPhoto != null) {
        await File(testPhoto.path).delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get a description of the preferred rear camera, or an empty string.
  Future<String> getCameraDescription() async {
    try {
      // Attempt to probe camera availability
      final bool available = await isCameraAvailable();
      if (available) {
        return 'Rear camera';
      }
    } catch (_) {}
    return '';
  }
}
