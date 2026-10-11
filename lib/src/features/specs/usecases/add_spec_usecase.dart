import 'package:agent_backlog/agent_backlog.dart';

import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/tdd_state.dart';

final class AddSpecResult {
  final Spec newSpec;
  final TddState currentState;

  const AddSpecResult({
    required this.newSpec,
    required this.currentState,
  });
}

final class AddSpecUseCase {
  final String projectDir;
  final SpecStore specStore;
  final TddCycle tddCycle;

  AddSpecUseCase({
    required this.projectDir,
    SpecStore? specStore,
    TddCycle? tddCycle,
  })  : specStore = specStore ?? FileSpecStore(projectDir, 'specs.yaml'),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  Future<AddSpecResult> execute(String title, {String? description}) async {
    await specStore.addSpec(title, description ?? '');
    final allSpecs = await specStore.specs();
    final newSpec = allSpecs.last;
    final currentState = await tddCycle.savedTddState();

    return AddSpecResult(
      newSpec: newSpec,
      currentState: currentState,
    );
  }
}
