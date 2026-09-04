import '../../../core/data/snapshot_store.dart';
import '../../../core/data/tdd_cycle.dart';

final class ResetCycleResult {
  final bool success;

  const ResetCycleResult({required this.success});
}

final class ResetCycleUseCase {
  final String projectDir;
  final SnapshotStore snapshotStore;
  final TddCycle tddCycle;

  ResetCycleUseCase({
    required this.projectDir,
    SnapshotStore? snapshotStore,
    TddCycle? tddCycle,
  })  : snapshotStore = snapshotStore ?? SnapshotStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  Future<ResetCycleResult> execute() async {
    await snapshotStore.delete();
    await tddCycle.reset();
    return const ResetCycleResult(success: true);
  }
}
