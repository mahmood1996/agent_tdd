import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../file_snapshot_diff/file_snapshot_diff.dart';
import 'pattern_file_snapshot.dart';

/// Abstract interface contract for capturing cryptographic file snapshots
abstract interface class FileSnapshot {
  Future<Map<String, String>> hashes();
}

/// Helper extensions on [FileSnapshot]
extension SmartFileSnapshot on FileSnapshot {
  /// Computes difference between this snapshot and another snapshot
  Future<FileSnapshotDiff> diff(FileSnapshot other) async {
    return FileSnapshotDiff(
      originalHashes: await hashes(),
      currentHashes: await other.hashes(),
    );
  }

  /// Checks if all files in this snapshot remain 100% unchanged on disk
  Future<bool> isUnchanged({String? baseDir}) async {
    final fileHashes = await hashes();
    final rootPath = baseDir ?? Directory.current.path;

    for (final entry in fileHashes.entries) {
      final file = File(p.join(rootPath, entry.key));

      if (!await file.exists()) return false;

      final stream = file.openRead();
      final currentHash = (await sha256.bind(stream).first).toString();

      if (currentHash != entry.value) return false;
    }

    return true;
  }

  /// Computes a diff between this snapshot and current state on disk
  Future<FileSnapshotDiff> diffFromDisk({String? baseDir}) async {
    return diff(
      PatternFileSnapshot(
        patterns: (await hashes()).keys.toList(),
        baseDir: baseDir,
      ),
    );
  }
}
