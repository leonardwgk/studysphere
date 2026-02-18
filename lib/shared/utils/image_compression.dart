import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses an image file to stay below [maxSizeBytes] (default 1 MB)
/// while maintaining the best possible quality.
///
/// Strategy:
///   1. Start at [initialQuality] (85).
///   2. Compress and check resulting size.
///   3. If still too large, drop quality by [qualityStep] (15) and retry.
///   4. Stop when under limit or [minQuality] (30) is reached.
///
/// Returns the compressed [File], or the original if compression fails.
Future<File> compressImage(
  File file, {
  int maxSizeBytes = 900 * 1024, // 900 KB — safe headroom below 1 MB
  int initialQuality = 85,
  int minQuality = 30,
  int qualityStep = 15,
}) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String baseName = DateTime.now().millisecondsSinceEpoch.toString();

    int quality = initialQuality;
    File? result;

    while (quality >= minQuality) {
      final String targetPath = '${tempDir.path}/${baseName}_q$quality.jpg';

      final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) break;

      final compressedFile = File(compressed.path);
      final int size = await compressedFile.length();

      debugPrint(
        '[ImageCompression] quality=$quality → ${(size / 1024).toStringAsFixed(1)} KB',
      );

      if (size <= maxSizeBytes) {
        result = compressedFile;
        break;
      }

      // Still too large — lower quality and try again
      quality -= qualityStep;
    }

    // Fallback: if we somehow exceeded min quality without meeting the size
    // target, return the last compressed file (better than nothing).
    if (result == null) {
      final String fallbackPath = '${tempDir.path}/${baseName}_fallback.jpg';
      final XFile? fallback = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        fallbackPath,
        quality: minQuality,
        format: CompressFormat.jpeg,
      );
      if (fallback != null) result = File(fallback.path);
    }

    return result ?? file; // Absolute fallback: return original
  } catch (e) {
    debugPrint('[ImageCompression] Failed: $e');
    return file;
  }
}

/// Deletes a temporary file silently (ignores errors).
Future<void> deleteTempFile(File file) async {
  try {
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
