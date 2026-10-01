import 'package:usecase/usecase.dart';

import '../out/file_snapshot_store.dart';

import '../../application/domain/services/delete_snapshot_service.dart';

abstract interface class DeleteSnapshot {
  /// Creates an adapter that calls [DeleteSnapshotService]
  /// using [FileSnapshotStore].
  ///
  /// The [snapshotPath] is the file where the snapshot will be saved.
  factory DeleteSnapshot({
    required String snapshotPath,
  }) =>
      _DeleteSnapshotAdapter(snapshotPath: snapshotPath);

  Future<void> call();
}

final class _DeleteSnapshotAdapter implements DeleteSnapshot {
  _DeleteSnapshotAdapter({
    required String snapshotPath,
  }) : _usecase = DeleteSnapshotService(
          snapshotStore: FileSnapshotStore(path: snapshotPath),
        );

  final Usecase<void> _usecase;

  @override
  Future<void> call() async => await _usecase();
}
