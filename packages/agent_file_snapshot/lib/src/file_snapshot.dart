import 'file_snapshot_diff.dart';

/// Immutable snapshot model mapping file paths to cryptographic SHA-256 signatures
final class FileSnapshot {
  final DateTime timestamp;
  final Map<String, String> fileHashes; // relative path -> sha256

  const FileSnapshot({
    required this.timestamp,
    required this.fileHashes,
  });

  /// Compares this snapshot against a newer snapshot
  FileSnapshotDiff compareTo(FileSnapshot other) {
    final modified = <String>[];
    final added = <String>[];
    final deleted = <String>[];

    fileHashes.forEach((path, hash) {
      if (!other.fileHashes.containsKey(path)) {
        deleted.add(path);
      } else if (other.fileHashes[path] != hash) {
        modified.add(path);
      }
    });

    other.fileHashes.forEach((path, hash) {
      if (!fileHashes.containsKey(path)) {
        added.add(path);
      }
    });

    return FileSnapshotDiff(
      modifiedFiles: modified,
      addedFiles: added,
      deletedFiles: deleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'file_hashes': fileHashes,
    };
  }

  factory FileSnapshot.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('file_hashes')) {
      return FileSnapshot(
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        fileHashes: (json['file_hashes'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v.toString()),
            ) ??
            const {},
      );
    }

    final hashes = <String, String>{};
    json.forEach((k, v) {
      if (k != 'timestamp') {
        hashes[k] = v.toString();
      }
    });

    return FileSnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      fileHashes: hashes,
    );
  }
}
