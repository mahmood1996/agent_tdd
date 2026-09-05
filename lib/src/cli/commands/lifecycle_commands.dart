import 'package:agent_harness/agent_harness.dart';
import '../../core/data/config_store.dart';
import '../../core/data/snapshot_store.dart';
import '../../core/data/spec_store.dart';
import '../../core/domain/tdd_state_extensions.dart';
import '../../core/services/git_client.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/next/usecases/start_next_cycle_usecase.dart';
import '../../features/reset/usecases/reset_cycle_usecase.dart';
import '../../features/status/usecases/get_status_usecase.dart';

final class LifecycleCommands {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;
  final SnapshotStore snapshotStore;
  final GitClient gitClient;
  final HarnessOutput output;

  const LifecycleCommands({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    required this.stateStore,
    required this.snapshotStore,
    required this.gitClient,
    this.output = const ConsoleOutput(isJsonMode: true),
  });

  Future<void> next() async {
    final useCase = StartNextCycleUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
    );
    final res = await useCase.execute();

    if (!res.success) {
      final state = await stateStore.harnessState();
      output.reportFailure(error: res.message, state: state);
      return;
    }

    final pendingSpec = res.activeSpec!;
    final config = res.config!;

    final state = HarnessState(
      phase: 'RED',
      editablePatterns: [config.testFiles],
      readOnlyPatterns: [config.sourceFiles, 'specs.yaml', '.tddrc.yaml'],
      nextCommand: 'agent-tdd verify-red',
      allowedCommands: const [
        'agent-tdd verify-red',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'active_spec': pendingSpec.toJson(),
      },
    );

    output.reportSuccess(
      message:
          'Write a failing unit test in ${config.testFiles} for Spec #${pendingSpec.id} "${pendingSpec.title}". Production code is strictly READ-ONLY. DO NOT edit or modify production code under any circumstances during the RED phase (if your test passes, expand your test assertions in ${config.testFiles} to test unhandled requirements). Run "agent-tdd verify-red" when ready.',
      state: state,
    );
  }

  Future<void> complete() async {
    final useCase = CompleteCycleUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
      snapshotStore: snapshotStore,
      gitClient: gitClient,
    );
    final res = await useCase.execute();

    if (!res.success) {
      final state = await stateStore.harnessState();
      output.reportFailure(error: res.message, state: state);
      return;
    }

    final state = HarnessState(
      phase: 'IDLE',
      editablePatterns: const [],
      readOnlyPatterns: const [],
      nextCommand: 'agent-tdd next',
      allowedCommands: const [
        'agent-tdd next',
        'agent-tdd specs',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'progress': res.summary,
      },
    );

    output.reportSuccess(
      message:
          'Spec #${res.completedSpecId} marked DONE! Run "agent-tdd next" to pick up the next pending spec item.',
      state: state,
    );
  }

  Future<void> status() async {
    final useCase = GetStatusUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
    );
    final res = await useCase.execute();

    final state = res.state.copyWith(
      metadata: {
        ...res.state.metadata,
        if (res.state.activeSpecId != null && res.state.activeSpecTitle != null)
          'active_spec': {
            'id': res.state.activeSpecId,
            'title': res.state.activeSpecTitle,
          },
        'progress': res.summary,
      },
    );

    output.reportSuccess(
      message: 'Current TDD phase: ${res.state.phase}.',
      state: state,
    );
  }

  Future<void> reset() async {
    final useCase = ResetCycleUseCase(
      projectDir: projectDir,
      snapshotStore: snapshotStore,
      stateStore: stateStore,
    );
    final res = await useCase.execute();

    if (!res.success) {
      final state = await stateStore.harnessState();
      output.reportFailure(error: 'Failed to reset TDD state machine.', state: state);
      return;
    }

    output.reportSuccess(
      message: 'TDD state machine reset to IDLE.',
      state: const HarnessState(
        phase: 'IDLE',
        editablePatterns: [],
        readOnlyPatterns: [],
        nextCommand: 'agent-tdd next',
        allowedCommands: [
          'agent-tdd next',
          'agent-tdd specs',
          'agent-tdd status',
          'agent-tdd reset',
        ],
      ),
    );
  }
}
