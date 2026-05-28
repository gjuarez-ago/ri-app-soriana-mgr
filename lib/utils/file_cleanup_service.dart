import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class FileCleanupService {
  // Define the size threshold for cleanup (25 MB)
  static const int _sizeThresholdBytes = 25 * 1024 * 1024;

  Future<void> shouldICleanUp(File file) async {
    final String filePath = file.path;

    // Extract the package root path
    final String? packageRootPath = _getPackageRootPath(filePath);

    if (packageRootPath == null || packageRootPath.isEmpty) {
      debugPrint('Error: Could not dynamically determine the package root path from: $filePath');
      return;
    }

    // Construct full paths for 'cache' and 'code_cache' directories
    final Directory cacheDir = Directory(p.join(packageRootPath, 'cache'));
    final Directory codeCacheDir = Directory(p.join(packageRootPath, 'code_cache'));

    debugPrint('--- Starting cleanup ---');
    debugPrint('Base package path: $packageRootPath');
    debugPrint('Directory to clean (cache): ${cacheDir.path}');
    debugPrint('Directory to clean (code_cache): ${codeCacheDir.path}');
    debugPrint('Cleanup threshold: ${_sizeThresholdBytes / (1024 * 1024)} MB');

    // Check and clean the 'cache' directory
    final bool cacheNeedsCleanup = await _doesDirectoryExceedSize(cacheDir, _sizeThresholdBytes);
    if (cacheNeedsCleanup) {
      debugPrint('\'cache\' directory size exceeds threshold. Proceeding with cleanup.');
      await _cleanDirectory(cacheDir, _shouldKeepCacheEntity);
    } else {
      debugPrint('\'cache\' directory size is within threshold. No cleanup required for \'cache\'.');
    }

    // Check and clean the 'code_cache' directory
    final bool codeCacheNeedsCleanup = await _doesDirectoryExceedSize(codeCacheDir, _sizeThresholdBytes);
    if (codeCacheNeedsCleanup) {
      debugPrint('\'code_cache\' directory size exceeds threshold. Proceeding with cleanup.');
      await _cleanDirectory(codeCacheDir, _shouldKeepCodeCacheEntity);
    } else {
      debugPrint('\'code_cache\' directory size is within threshold. No cleanup required for \'code_cache\'.');
    }

    debugPrint('--- Cleanup finished ---');
  }

  /// Helper function to extract the package root path from a given file path.
  ///
  /// Assumes the package root is the segment preceding '/cache/' or '/code_cache/'.
  /// Returns null if the pattern is not found.
  String? _getPackageRootPath(String filePath) {
    if (filePath.contains('/cache/')) {
      return filePath.substring(0, filePath.indexOf('/cache/'));
    } else if (filePath.contains('/code_cache/')) {
      return filePath.substring(0, filePath.indexOf('/code_cache/'));
    }
    return null;
  }

  /// Generic helper function to clean a directory based on a provided predicate.
  ///
  /// [dir]: The Directory to be cleaned.
  /// [shouldKeepPredicate]: A function that takes a FileSystemEntity and returns
  ///                        true if the entity should be kept, false otherwise.
  Future<void> _cleanDirectory(
    Directory dir,
    bool Function(FileSystemEntity entity) shouldKeepPredicate,
  ) async {
    if (!await dir.exists()) {
      debugPrint('Directory does not exist: ${dir.path}. No cleanup required.');
      return;
    }

    debugPrint('\nCleaning directory: ${dir.path}');
    try {
      await for (FileSystemEntity entity in dir.list(recursive: false)) {
        if (!shouldKeepPredicate(entity)) {
          await entity.delete(recursive: true);
          debugPrint('\tDeleted from ${p.basename(dir.path)}: ${entity.path}');
        } else {
          debugPrint('\tPreserving in ${p.basename(dir.path)}: ${entity.path}');
        }
      }
      debugPrint('Directory ${p.basename(dir.path)} cleanup completed.');
    } catch (e) {
      debugPrint('Error cleaning directory ${dir.path}: $e');
    }
  }

  /// Checks if the total size of a directory exceeds a given threshold.
  /// This function stops calculating as soon as the threshold is met.
  ///
  /// [dir]: The Directory whose size is to be checked.
  /// [thresholdBytes]: The size threshold in bytes.
  /// Returns true if the directory size exceeds the threshold, false otherwise.
  Future<bool> _doesDirectoryExceedSize(Directory dir, int thresholdBytes) async {
    if (!await dir.exists()) {
      return false; // Directory doesn't exist, so it doesn't exceed the size.
    }

    int currentSize = 0;
    try {
      // List all entities recursively to sum their sizes
      await for (FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final fileExtension = p.extension(entity.path).toLowerCase();
          final isImg = (fileExtension == '.jpg' || fileExtension == '.jpeg');
          final length = await entity.length();
          if (length == 0 && isImg) {
            debugPrint('Deleting empty image file: ${entity.path}');
            await entity.delete();
            continue; // Jump to the next file in the list.
          }

          currentSize += await length;
          // Crucial optimization: If the current size already exceeds the threshold, stop and return true.
          if (currentSize > thresholdBytes) {
            debugPrint('  (Optimizando) Tamaño de ${dir.path} superó el umbral. Actual: ${currentSize / (1024 * 1024)} MB');
            return true;
          }
        } else if (entity is Directory) {
          if (_shouldKeepDirectory(entity)) {
            debugPrint('Skipping vital directory deletion: ${entity.path}');
            continue;
          }

          final dirContents = await entity.list().toList();
          if (dirContents.isEmpty) {
            debugPrint('Deleting empty child directory: ${entity.path}');
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking directory size for ${dir.path}: $e');
      // In case of error, err on the side of caution and assume it might need cleanup
      return true; // Assume it needs cleanup if there's an error getting size
    }

    // If the loop completes, it means the total size did not exceed the threshold.
    return false;
  }

  /// Predicate function for the 'cache' directory cleanup.
  /// Keeps only the "libCachedImageData" directory.
  bool _shouldKeepCacheEntity(FileSystemEntity entity) {
    final String entityName = p.basename(entity.path);
    return entityName == 'libCachedImageData';
  }

  /// Predicate function for the 'code_cache' directory cleanup.
  /// Keeps "flutter-cache" and any directory starting with "ri-app".
  bool _shouldKeepCodeCacheEntity(FileSystemEntity entity) {
    final String entityName = p.basename(entity.path);
    // Only directories can be kept under these rules. Files will always be deleted.
    if (entity is Directory) {
      return entityName.startsWith('flutter') || entityName.startsWith('ri-app');
    }

    if (entity is File) {
      return entityName.contains('flutter.impeller.vkcache');
    }
    return false; // Files are not kept
  }

  bool _shouldKeepDirectory(Directory directory) {
    final String dirName = p.basename(directory.path);

    if (p.basename(directory.parent.path) == 'cache') {
      return dirName == 'libCachedImageData';
    }

    if (p.basename(directory.parent.path) == 'code_cache') {
      return dirName.startsWith('flutter') || dirName.startsWith('ri-app');
    }
    return false;
  }
}
