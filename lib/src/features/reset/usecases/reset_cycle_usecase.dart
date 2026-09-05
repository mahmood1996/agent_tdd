import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/snapshot_store.dart';

final class ResetCycleResult {
  final bool success;

  const ResetCycleResult({required this.success});
}

final class ResetCycleUseCase {
  final String projectDir;
  final SnapshotStore snapshotStore;
  final StateStore stateStore;

  ResetCycleUseCase({
    required this.projectDir,
    SnapshotStore? snapshotStore,
    StateStore? stateStore,
  })  : snapshotStore = snapshotStore ?? SnapshotStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir);

  Future<ResetCycleResult> execute() async {
    await snapshotStore.delete();
    await stateStore.resetState();
    return const ResetCycleResult(success: true);
  }
}
