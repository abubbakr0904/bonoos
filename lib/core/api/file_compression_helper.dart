import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Add these dependencies to pubspec.yaml:
// flutter_image_compress: ^2.0.4
// path_provider: ^2.1.1
// path: ^1.8.3

class FileCompressionHelper {
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB for images
  static const int imageQuality = 85; // Image compression quality (0-100)

  // Compress image file
  static Future<File?> compressImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileSize = await file.length();
      if (fileSize <= maxImageSizeBytes) return file;

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(filePath);
      final extension = path.extension(filePath).toLowerCase();

      // Define target file path
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_compressed$extension',
      );

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: imageQuality,
        minWidth: 1920, // Max width
        minHeight: 1080, // Max height
        format: _getCompressFormat(extension),
      );

      if (compressedFile != null) {
        final compressedSize = await compressedFile.length();
        print('Original size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
        print('Compressed size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

        // If still too large, compress more aggressively
        if (compressedSize > maxImageSizeBytes) {
          return await _compressImageAggressively(filePath, targetPath);
        }

        return File(compressedFile.path);
      }

      return file;
    } catch (e) {
      print('Error compressing image: $e');
      return File(filePath);
    }
  }

  // More aggressive image compression
  static Future<File?> _compressImageAggressively(String originalPath, String targetPath) async {
    try {
      int quality = 70;
      int maxWidth = 1280;
      int maxHeight = 720;

      while (quality > 20) {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          originalPath,
          targetPath.replaceAll('_compressed', '_compressed_$quality'),
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
          format: CompressFormat.jpeg, // Force JPEG for better compression
        );

        if (compressedFile != null) {
          final size = await compressedFile.length();
          if (size <= maxImageSizeBytes) {
            return File(compressedFile.path);
          }
        }

        quality -= 15;
        maxWidth = (maxWidth * 0.8).round();
        maxHeight = (maxHeight * 0.8).round();
      }

      return null;
    } catch (e) {
      print('Error in aggressive compression: $e');
      return null;
    }
  }

  // Compress general files (for non-image files)
  static Future<File?> compressFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileSize = await file.length();
      if (fileSize <= maxFileSizeBytes) return file;

      // For non-image files, we can't compress them directly
      // You might want to show an error or ask user to choose a smaller file
      print('File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      throw Exception('File size exceeds 10MB limit. Please choose a smaller file.');
    } catch (e) {
      print('Error checking file size: $e');
      rethrow;
    }
  }

  // Get compression format based on file extension
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return CompressFormat.jpeg;
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }

  // Check if file is an image
  static bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.bmp', '.gif']
        .contains(extension);
  }

  // Check if file is an audio file
  static bool isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp3', '.wav', '.aac', '.m4a', '.ogg', '.flac']
        .contains(extension);
  }
}