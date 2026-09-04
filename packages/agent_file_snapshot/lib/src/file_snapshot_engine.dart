import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'file_snapshot.dart';
import 'file_snapshot_diff.dart';

/// Engine responsible for computing SHA-256 hashes of files matching glob patterns
final class FileSnapshotEngine {
  /// Computes SHA-256 hashes for all files matching [patterns] relative to [baseDir]
  Future<FileSnapshot> computeHashes(
    List<String> patterns, {
    String? baseDir,
  }) async {
    final rootPath = baseDir ?? Directory.current.path;
    final rootDir = Directory(rootPath);
    final fileHashes = <String, String>{};

    if (!await rootDir.exists()) {
      return FileSnapshot(timestamp: DateTime.now(), fileHashes: const {});
    }

    final globs = patterns.map((p) => Glob(p)).toList();
    final fallbackGlobs = patterns
        .where((p) => p.contains('/**/'))
        .map((p) => Glob(p.replaceAll('/**/', '/*')))
        .toList();

    await for (final entity in rootDir.list(recursive: true)) {
      if (entity is! File) continue;

      final relPath =
          p.relative(entity.path, from: rootPath).replaceAll('\\', '/');

      final isMatch = globs.any((g) => g.matches(relPath)) ||
          fallbackGlobs.any((g) => g.matches(relPath));

      if (isMatch) {
        final bytes = await entity.readAsBytes();
        fileHashes[relPath] = sha256.convert(bytes).toString();
      }
    }

    return FileSnapshot(
      timestamp: DateTime.now(),
      fileHashes: fileHashes,
    );
  }

  /// Verifies that all files in [snapshot] remain 100% unchanged on disk
  Future<bool> verifyUnchanged(
    FileSnapshot snapshot, {
    String? baseDir,
  }) async {
    final rootPath = baseDir ?? Directory.current.path;

    for (final entry in snapshot.fileHashes.entries) {
      final file = File(p.join(rootPath, entry.key));

      if (!file.existsSync()) {
        return false; // File was deleted
      }

      final bytes = await file.readAsBytes();
      final currentHash = sha256.convert(bytes).toString();

      if (currentHash != entry.value) {
        return false; // File was modified
      }
    }

    return true;
  }

  /// Computes a diff between [before] snapshot and current state on disk
  Future<FileSnapshotDiff> checkDiff(
    FileSnapshot before, {
    String? baseDir,
  }) async {
    final current = await computeHashes(
      before.fileHashes.keys.toList(),
      baseDir: baseDir,
    );
    return before.compareTo(current);
  }
}
