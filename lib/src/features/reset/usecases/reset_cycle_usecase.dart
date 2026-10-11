import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

import '../../../core/data/tdd_state_store.dart';
import '../../../core/domain/tdd_constants.dart';

final class ResetCycleResult {
  final bool success;

  const ResetCycleResult({required this.success});
}

final class ResetCycleUseCase {
  ResetCycleUseCase({
    required String projectDir,
    DeleteSnapshot? deleteSnapshot,
    TddStateStore? stateStore,
  })  : deleteSnapshot = deleteSnapshot ??
            DeleteSnapshot(
              snapshotPath: p.join(projectDir, TddConstants.snapshotFileName),
            ),
        stateStore = stateStore ?? TddStateStore(projectDir: projectDir);

  final TddStateStore stateStore;

  final DeleteSnapshot deleteSnapshot;

  Future<ResetCycleResult> execute() async {
    await deleteSnapshot();
    await stateStore.reset();
    return const ResetCycleResult(success: true);
  }
}
