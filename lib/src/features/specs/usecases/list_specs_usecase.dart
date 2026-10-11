import 'package:agent_backlog/agent_backlog.dart';

import '../../../core/data/tdd_state_store.dart';
import 'package:tdd_spec_store/tdd_spec_store.dart';
import '../../../core/domain/tdd_state.dart';

final class ListSpecsResult {
  final TddState currentState;
  final Map<String, dynamic> summary;
  final List<Spec> specs;

  const ListSpecsResult({
    required this.currentState,
    required this.summary,
    required this.specs,
  });
}

final class ListSpecsUseCase {
  final String projectDir;
  final TddSpecStore specStore;
  final TddStateStore stateStore;

  ListSpecsUseCase({
    required this.projectDir,
    TddSpecStore? specStore,
    TddStateStore? stateStore,
  })  : specStore = specStore ?? TddSpecStore.file(projectDir),
        stateStore = stateStore ?? TddStateStore(projectDir: projectDir);

  Future<ListSpecsResult> execute() async {
    final currentState = await stateStore.currentState();
    final summary = await specStore.summary();
    final specs = await specStore.specs();

    return ListSpecsResult(
      currentState: currentState,
      summary: summary,
      specs: specs,
    );
  }
}
