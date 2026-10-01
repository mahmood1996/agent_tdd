import 'package:usecase/usecase.dart';

import '../out/file_snapshot_store.dart';
import '../out/disk_file_index.dart';

import '../../application/domain/services/capture_snapshot_service.dart';

abstract interface class CaptureSnapshot {
  /// Creates an adapter that calls [CaptureSnapshotService]
  /// using [DiskFileIndex] and [FileSnapshotStore].
  ///
  /// The [baseDir] is the root directory to search for files,
  /// and [snapshotPath] is the file where the snapshot will be saved.
  factory CaptureSnapshot({
    required String baseDir,
    required String snapshotPath,
  }) =>
      _CaptureSnapshotAdapter(
        baseDir: baseDir,
        snapshotPath: snapshotPath,
      );

  Future<void> call(String globPattern);
}

final class _CaptureSnapshotAdapter implements CaptureSnapshot {
  _CaptureSnapshotAdapter({
    required String baseDir,
    required String snapshotPath,
  }) : this._(
          CaptureSnapshotService(
            fileIndex: DiskFileIndex(baseDir: baseDir),
            snapshotStore: FileSnapshotStore(path: snapshotPath),
          ),
        );

  _CaptureSnapshotAdapter._(this._usecase);

  final ParameterizedUsecase<void, String> _usecase;

  @override
  Future<void> call(String globPattern) async => await _usecase(globPattern);
}
