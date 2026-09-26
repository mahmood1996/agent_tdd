import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/tdd_constants.dart';

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
  })  : snapshotStore = snapshotStore ??
            FileSnapshotStore(
              path: p.join(projectDir, TddConstants.snapshotFileName),
            ),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  Future<ResetCycleResult> execute() async {
    await snapshotStore.delete();
    await tddCycle.reset();
    return const ResetCycleResult(success: true);
  }
}
