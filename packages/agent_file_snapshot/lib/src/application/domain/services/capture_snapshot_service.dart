import 'package:usecase/usecase.dart';

import '../../ports/out/file_index.dart';
import '../../ports/out/snapshot_store.dart';

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
final class CaptureSnapshotService
    implements ParameterizedUsecase<void, String> {
  const CaptureSnapshotService({
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
