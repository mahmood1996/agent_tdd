import 'dart:collection';

import '../file_snapshot_diff/file_snapshot_diff.dart';

/// Abstract interface representing a point-in-time state of a set of files.
///
/// A [FileSnapshot] is a pure value object — it holds already-computed
/// fingerprints and performs no I/O. Use [FileIndex] to produce a snapshot
/// from disk.
abstract interface class FileSnapshot {
  /// The paths of all files captured in this snapshot.
  Iterable<String> get filePaths;

  /// Returns the fingerprint (SHA-256 hash) of [filePath] in this snapshot.
  String fingerprint(String filePath);

  /// Creates a [FileSnapshot] from a map of file paths to fingerprints.
  factory FileSnapshot(Map<String, String> fingerprints) = _FileSnapshotImpl;
}

/// Helper extensions on [FileSnapshot].
extension SmartFileSnapshot on FileSnapshot {
  bool get hasFingerprints => FingerPrints(this).isNotEmpty;

  /// Computes the difference between this snapshot and [other].
  FileSnapshotDiff diff(
    FileSnapshot other,
  ) =>
      FileSnapshotDiff(
        originalHashes: FingerPrints(this),
        currentHashes: FingerPrints(other),
      );
}

final class _FileSnapshotImpl implements FileSnapshot {
  final Map<String, String> _fingerprints;

  const _FileSnapshotImpl(this._fingerprints);

  @override
  Iterable<String> get filePaths => _fingerprints.keys;

  @override
  String fingerprint(String filePath) => _fingerprints[filePath] ?? '';
}

final class FingerPrints extends UnmodifiableMapBase<String, String> {
  FingerPrints(this._snapshot);

  final FileSnapshot _snapshot;

  @override
  String? operator [](Object? key) => _snapshot.fingerprint(key.toString());

  @override
  Iterable<String> get keys => _snapshot.filePaths;
}
