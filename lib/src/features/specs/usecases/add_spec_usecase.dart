import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/spec_item.dart';

final class AddSpecResult {
  final SpecItem newSpec;
  final HarnessState currentState;

  const AddSpecResult({
    required this.newSpec,
    required this.currentState,
  });
}

final class AddSpecUseCase {
  final String projectDir;
  final SpecStore specStore;
  final StateStore stateStore;

  AddSpecUseCase({
    required this.projectDir,
    SpecStore? specStore,
    StateStore? stateStore,
  })  : specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir);

  Future<AddSpecResult> execute(String title, {String? description}) async {
    await specStore.addSpec(title, description: description);
    final allSpecs = await specStore.specs();
    final newSpec = allSpecs.last;
    final currentState = await stateStore.harnessState();

    return AddSpecResult(
      newSpec: newSpec,
      currentState: currentState,
    );
  }
}
