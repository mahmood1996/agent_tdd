import 'package:usecase/usecase.dart';

import '../../data/file_index/file_index.dart';
import '../../data/snapshot_store/snapshot_store.dart';
import '../models/file_snapshot/file_snapshot.dart';
import '../models/file_snapshot_diff/file_snapshot_diff.dart';

/// A [ParameterizedUsecase] that returns the list of integrity violations
/// between the previously saved [FileSnapshot] and the current state of files
/// matching [globPattern].
///
/// Violations are formatted as human-readable strings:
/// - `"<path> (MODIFIED)"`
/// - `"<path> (DELETED)"`
/// - `"<path> (ADDED)"`
///
/// An empty list means no violations were detected.
///
/// Usage:
/// ```dart
/// final check = IntegrityViolations(
///   fileIndex: DiskFileIndex(baseDir: projectDir),
///   snapshotStore: FileSnapshotStore(path: '.snapshot.json'),
/// );
/// final violations = await check('test/**/*_test.dart');
/// ```
final class IntegrityViolations
    implements ParameterizedUsecase<List<String>, String> {
  const IntegrityViolations({
    required FileIndex fileIndex,
    required SnapshotStore snapshotStore,
  })  : _fileIndex = fileIndex,
        _snapshotStore = snapshotStore;

  final FileIndex _fileIndex;
  final SnapshotStore _snapshotStore;

  /// Returns a list of violation strings by diffing the saved [FileSnapshot]
  /// against a fresh snapshot of files matching [globPattern].
  ///
  /// Returns an empty list immediately if no snapshot has been saved yet
  /// (i.e. the saved snapshot contains no file entries) — there is nothing
  /// to compare against, so no violations are possible.
  @override
  Future<List<String>> call(String globPattern) async {
    final saved = await _snapshotStore.savedSnapshot();
    if (saved.fingerprints.isEmpty) return const [];

    final current = await _fileIndex.snapshotOf([globPattern]);
    return saved.diff(current).violations;
  }
}

extension _ViolationsFromDiff on FileSnapshotDiff {
  List<String> get violations {
    return [
      ...modifiedFiles.map((f) => '$f (MODIFIED)'),
      ...deletedFiles.map((f) => '$f (DELETED)'),
      ...addedFiles.map((f) => '$f (ADDED)'),
    ];
  }
}
