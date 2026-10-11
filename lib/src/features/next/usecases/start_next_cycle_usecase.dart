import 'package:agent_backlog/agent_backlog.dart';

import '../../../core/data/config_store.dart';
import '../../../core/data/tdd_state_store.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state.dart';

final class StartNextCycleResult {
  final bool success;
  final TddState currentState;
  final Spec? activeSpec;
  final TddConfig? config;
  final String message;

  const StartNextCycleResult({
    required this.success,
    required this.currentState,
    this.activeSpec,
    this.config,
    required this.message,
  });
}

final class StartNextCycleUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final TddStateStore stateStore;

  StartNextCycleUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    TddStateStore? stateStore,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? FileSpecStore(projectDir, 'specs.yaml'),
        stateStore = stateStore ?? TddStateStore(projectDir: projectDir);

  Future<StartNextCycleResult> execute() async {
    final currentState = await stateStore.currentState();

    if (currentState.phase != TddPhase.idle) {
      final msg =
          'Cannot start next spec while another cycle is in progress (Current phase: ${currentState.phase.name.toUpperCase()}). Complete or reset current cycle first.';
      return StartNextCycleResult(
        success: false,
        currentState: currentState,
        message: msg,
      );
    }

    final pendingSpec = await specStore.nextPendingSpec();
    if (pendingSpec == null) {
      const msg =
          'No pending specs found in backlog! Add specs to specs.yaml or specs.md first.';
      return StartNextCycleResult(
        success: false,
        currentState: currentState,
        message: msg,
      );
    }

    final newState = TddState.red(pendingSpec);
    await stateStore.save(newState);
    await specStore.updateSpecStatus(pendingSpec.id, 'red');

    final config = await configStore.config();

    return StartNextCycleResult(
      success: true,
      currentState: newState,
      activeSpec: pendingSpec,
      config: config,
      message: 'Active Spec #${pendingSpec.id}: "${pendingSpec.title}"',
    );
  }
}
