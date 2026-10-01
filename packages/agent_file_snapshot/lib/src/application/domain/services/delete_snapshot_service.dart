import 'package:usecase/usecase.dart';

import '../../ports/out/snapshot_store.dart';

final class DeleteSnapshotService implements Usecase<void> {
  DeleteSnapshotService({
    required SnapshotStore snapshotStore,
  }) : _snapshotStore = snapshotStore;

  final SnapshotStore _snapshotStore;

  @override
  Future<void> call() async => await _snapshotStore.delete();
}
