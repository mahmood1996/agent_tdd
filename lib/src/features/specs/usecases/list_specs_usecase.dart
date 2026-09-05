import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/spec_item.dart';

final class ListSpecsResult {
  final HarnessState currentState;
  final Map<String, dynamic> summary;
  final List<SpecItem> specs;

  const ListSpecsResult({
    required this.currentState,
    required this.summary,
    required this.specs,
  });
}

final class ListSpecsUseCase {
  final String projectDir;
  final SpecStore specStore;
  final StateStore stateStore;

  ListSpecsUseCase({
    required this.projectDir,
    SpecStore? specStore,
    StateStore? stateStore,
  })  : specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir);

  Future<ListSpecsResult> execute() async {
    final currentState = await stateStore.harnessState();
    final summary = await specStore.summary();
    final specs = await specStore.specs();

    return ListSpecsResult(
      currentState: currentState,
      summary: summary,
      specs: specs,
    );
  }
}
