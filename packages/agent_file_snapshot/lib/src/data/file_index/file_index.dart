import '../../domain/models/file_snapshot/file_snapshot.dart';

/// Abstract interface for producing a [FileSnapshot] from file glob patterns.
///
/// A [FileIndex] knows how to traverse a set of files and produce a
/// point-in-time [FileSnapshot]. It is the async boundary — all I/O
/// happens here, not inside [FileSnapshot] itself.
///
/// Example:
/// ```dart
/// final index = DiskFileIndex(baseDir: projectDir);
/// final snapshot = await index.snapshotOf(['test/**/*_test.dart']);
/// ```
abstract interface class FileIndex {
  /// Returns a [FileSnapshot] of all files matching the given [patterns].
  Future<FileSnapshot> snapshotOf(List<String> patterns);
}
