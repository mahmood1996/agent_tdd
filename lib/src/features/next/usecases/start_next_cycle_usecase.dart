import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/config_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/spec_item.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state_extensions.dart';

final class StartNextCycleResult {
  final bool success;
  final HarnessState currentState;
  final SpecItem? activeSpec;
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
  final StateStore stateStore;

  StartNextCycleUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    StateStore? stateStore,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir);

  Future<StartNextCycleResult> execute() async {
    final currentState = await stateStore.harnessState();

    if (!currentState.isIdle) {
      final msg =
          'Cannot start next spec while another cycle is in progress (Current phase: ${currentState.phase}). Complete or reset current cycle first.';
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

    final newState = TddHarnessState.red(
      activeSpecId: pendingSpec.id,
      activeSpecTitle: pendingSpec.title,
    );
    await stateStore.saveState(newState);
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
