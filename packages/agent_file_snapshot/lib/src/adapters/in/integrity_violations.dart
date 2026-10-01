import 'package:usecase/usecase.dart';

import '../../application/domain/services/integrity_violations_service.dart';
import '../out/disk_file_index.dart';
import '../out/file_snapshot_store.dart';

abstract interface class IntegrityViolations {
  /// Creates an adapter that calls [IntegrityViolationsService]
  /// using [DiskFileIndex] and [FileSnapshotStore].
  ///
  /// The [baseDir] is the root directory to search for files,
  /// and [snapshotPath] is the file where the snapshot will be saved.
  factory IntegrityViolations({
    required String baseDir,
    required String snapshotPath,
  }) =>
      _IntegrityViolationsAdapter(
        baseDir: baseDir,
        snapshotPath: snapshotPath,
      );

  Future<List<String>> call(String globPattern);
}

final class _IntegrityViolationsAdapter implements IntegrityViolations {
  _IntegrityViolationsAdapter({
    required String baseDir,
    required String snapshotPath,
  }) : this._(
          IntegrityViolationsService(
            fileIndex: DiskFileIndex(baseDir: baseDir),
            snapshotStore: FileSnapshotStore(path: snapshotPath),
          ),
        );
  _IntegrityViolationsAdapter._(this._usecase);

  final ParameterizedUsecase<List<String>, String> _usecase;

  @override
  Future<List<String>> call(String globPattern) async =>
      await _usecase(globPattern);
}
