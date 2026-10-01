import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/tdd_constants.dart';

final class ResetCycleResult {
  final bool success;

  const ResetCycleResult({required this.success});
}

final class ResetCycleUseCase {
  ResetCycleUseCase({
    required String projectDir,
    DeleteSnapshot? deleteSnapshot,
    TddCycle? tddCycle,
  })  : deleteSnapshot = deleteSnapshot ??
            DeleteSnapshot(
              snapshotPath: p.join(projectDir, TddConstants.snapshotFileName),
            ),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  final TddCycle tddCycle;

  final DeleteSnapshot deleteSnapshot;

  Future<ResetCycleResult> execute() async {
    await deleteSnapshot();
    await tddCycle.reset();
    return const ResetCycleResult(success: true);
  }
}
