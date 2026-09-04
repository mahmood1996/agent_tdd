import '../../../core/data/spec_store.dart';
import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/spec_item.dart';
import '../../../core/domain/tdd_state.dart';

final class ListSpecsResult {
  final TddState currentState;
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
  final TddCycle tddCycle;

  ListSpecsUseCase({
    required this.projectDir,
    SpecStore? specStore,
    TddCycle? tddCycle,
  })  : specStore = specStore ?? SpecStore(projectDir: projectDir),
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


