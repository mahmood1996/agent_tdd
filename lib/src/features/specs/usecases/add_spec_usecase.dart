import '../../../core/data/spec_store.dart';
import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/spec_item.dart';
import '../../../core/domain/tdd_state.dart';

final class AddSpecResult {
  final SpecItem newSpec;
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
  })  : specStore = specStore ?? SpecStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir);

  Future<AddSpecResult> execute(String title, {String? description}) async {
    await specStore.addSpec(title, description: description);
    final allSpecs = await specStore.specs();
    final newSpec = allSpecs.last;
    final currentState = await tddCycle.savedTddState();

    return AddSpecResult(
      newSpec: newSpec,
      currentState: currentState,
    );
  }
}


