import 'package:usecase/usecase.dart';

import '../../data/file_index/file_index.dart';
import '../../data/snapshot_store/snapshot_store.dart';

/// A [ParameterizedUsecase] that captures a snapshot of files matching
/// [globPattern] via [FileIndex] and persists it through [SnapshotStore].
///
/// Usage:
/// ```dart
/// final capture = CaptureSnapshot(
///   fileIndex: DiskFileIndex(baseDir: projectDir),
///   snapshotStore: FileSnapshotStore(path: '.snapshot.json'),
/// );
/// await capture('test/**/*_test.dart');
/// ```
final class CaptureSnapshot implements ParameterizedUsecase<void, String> {
  const CaptureSnapshot({
    required FileIndex fileIndex,
    required SnapshotStore snapshotStore,
  })  : _fileIndex = fileIndex,
        _snapshotStore = snapshotStore;

  final FileIndex _fileIndex;
  final SnapshotStore _snapshotStore;

  /// Captures a [FileSnapshot] of all files matching [globPattern] and saves
  /// it to the [SnapshotStore].
  @override
  Future<void> call(String globPattern) async {
    await _snapshotStore.save(
      await _fileIndex.snapshotOf([globPattern]),
    );
  }
}
