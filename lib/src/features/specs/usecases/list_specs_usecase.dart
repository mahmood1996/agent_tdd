import 'package:agent_backlog/agent_backlog.dart';

import '../../../core/data/tdd_cycle.dart';
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
  final TddCycle tddCycle;

  ListSpecsUseCase({
    required this.projectDir,
    TddSpecStore? specStore,
    TddCycle? tddCycle,
  })  : specStore = specStore ?? TddSpecStore.file(projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  Future<ListSpecsResult> execute() async {
    final currentState = await tddCycle.savedTddState();
    final summary = await specStore.summary();
    final specs = await specStore.specs();

    return ListSpecsResult(
      currentState: currentState,
      summary: summary,
      specs: specs,
    );
  }
}
