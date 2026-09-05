import 'package:agent_harness/agent_harness.dart';
import '../../core/data/config_store.dart';
import '../../core/data/snapshot_store.dart';
import '../../core/data/spec_store.dart';
import '../../core/domain/tdd_state_extensions.dart';
import '../../core/services/analyzer.dart';
import '../../core/services/git_client.dart';
import '../../core/services/test_run_verifications.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/verify_green/usecases/verify_green_usecase.dart';
import '../../features/verify_red/usecases/verify_red_usecase.dart';
import '../../features/verify_refactor/usecases/verify_refactor_usecase.dart';

final class VerificationCommands {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;
  final SnapshotStore snapshotStore;
  final TestRunVerifications testRunVerifications;
  final Analyzer analyzer;
  final GitClient gitClient;
  final HarnessOutput output;

  const VerificationCommands({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    required this.stateStore,
    required this.snapshotStore,
    required this.testRunVerifications,
    required this.analyzer,
    required this.gitClient,
    this.output = const ConsoleOutput(isJsonMode: true),
  });

  Future<void> verifyRed() async {
    final useCase = VerifyRedUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
      snapshotStore: snapshotStore,
      testRunVerifications: testRunVerifications,
      gitClient: gitClient,
    );
    final res = await useCase.execute();

    if (!res.success) {
      final config = res.config ?? await configStore.config();
      _renderError(
        message: res.message,
        phase: res.state.phase,
        activeSpec: _activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        editableFiles: [config.testFiles],
        readOnlyFiles: [config.sourceFiles, 'specs.yaml', '.tddrc.yaml'],
        nextCommand: 'agent-tdd verify-red',
      );
      return;
    }

    final state = res.state;
    if (state.isAlreadyPassed) {
      final completeUseCase = CompleteCycleUseCase(
        projectDir: projectDir,
        configStore: configStore,
        specStore: specStore,
        stateStore: stateStore,
        snapshotStore: snapshotStore,
        gitClient: gitClient,
      );
      final completeRes = await completeUseCase.execute();

      final stateObj = HarnessState(
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
          'progress': completeRes.summary,
        },
      );
      output.reportSuccess(
        message:
            'Test PASSED! Spec #${state.activeSpecId} "${state.activeSpecTitle}" was already satisfied in existing production code. Cycle automatically completed! Run "agent-tdd next" to pick up the next pending spec.',
        state: stateObj,
      );
      return;
    }

    final config = res.config!;
    final stateObj = HarnessState(
      phase: 'GREEN',
      editablePatterns: [config.sourceFiles],
      readOnlyPatterns: [config.testFiles, 'specs.yaml', '.tddrc.yaml'],
      nextCommand: 'agent-tdd verify-green',
      allowedCommands: const [
        'agent-tdd verify-green',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        if (_activeSpecMap(state.activeSpecId, state.activeSpecTitle) != null)
          'active_spec': _activeSpecMap(state.activeSpecId, state.activeSpecTitle)!,
      },
    );
    output.reportSuccess(
      message:
          'Test failed as expected. Test files (${config.testFiles}) are cryptographically FROZEN. Write minimal production code in ${config.sourceFiles} to pass the test. Run "agent-tdd verify-green" when done.',
      state: stateObj,
    );
  }

  Future<void> verifyGreen() async {
    final useCase = VerifyGreenUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
      snapshotStore: snapshotStore,
      testRunVerifications: testRunVerifications,
      gitClient: gitClient,
    );
    final res = await useCase.execute();

    if (!res.success) {
      _renderError(
        message: res.message,
        phase: res.state.phase,
        activeSpec: _activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        issues: res.violations.isNotEmpty
            ? res.violations.map((v) => {'violation': v}).toList()
            : null,
      );
      return;
    }

    final config = res.config!;
    final state = res.state;

    final stateObj = HarnessState(
      phase: 'REFACTOR',
      editablePatterns: [config.sourceFiles, config.testFiles],
      readOnlyPatterns: const ['specs.yaml', '.tddrc.yaml'],
      nextCommand: 'agent-tdd verify-refactor',
      allowedCommands: const [
        'agent-tdd verify-refactor',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        if (_activeSpecMap(state.activeSpecId, state.activeSpecTitle) != null)
          'active_spec': _activeSpecMap(state.activeSpecId, state.activeSpecTitle)!,
      },
    );
    output.reportSuccess(
      message:
          '100% of tests passed! You are now in the REFACTOR phase. Clean up code/tests if needed, then run "agent-tdd verify-refactor".',
      state: stateObj,
    );
  }

  Future<void> verifyRefactor() async {
    final useCase = VerifyRefactorUseCase(
      projectDir: projectDir,
      configStore: configStore,
      stateStore: stateStore,
      testRunVerifications: testRunVerifications,
      analyzer: analyzer,
    );
    final res = await useCase.execute();

    if (!res.success) {
      _renderError(
        message: res.message,
        phase: 'REFACTOR',
        activeSpec: _activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        issues: res.analysisIssues.isNotEmpty
            ? res.analysisIssues.map((i) => i.toJson()).toList()
            : null,
      );
      return;
    }

    final state = res.state;
    final config = res.config ?? await configStore.config();

    final stateObj = HarnessState(
      phase: 'REFACTOR',
      editablePatterns: [config.sourceFiles, config.testFiles],
      readOnlyPatterns: const ['specs.yaml', '.tddrc.yaml'],
      nextCommand: 'agent-tdd complete',
      allowedCommands: const [
        'agent-tdd complete',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        if (_activeSpecMap(state.activeSpecId, state.activeSpecTitle) != null)
          'active_spec': _activeSpecMap(state.activeSpecId, state.activeSpecTitle)!,
      },
    );
    output.reportSuccess(
      message:
          'Refactor phase verified! 100% tests passed, 0 analysis warnings/errors. Run "agent-tdd complete" to finish Spec #${state.activeSpecId}.',
      state: stateObj,
    );
  }

  void _renderError({
    required String message,
    required String phase,
    Map<String, dynamic>? activeSpec,
    List<String> editableFiles = const [],
    List<String> readOnlyFiles = const [],
    String? nextCommand,
    List<String>? allowedCommands,
    List<dynamic>? issues,
  }) {
    final defaultAllowed = allowedCommands ??
        switch (phase.toUpperCase()) {
          'RED' => const [
              'agent-tdd verify-red',
              'agent-tdd status',
              'agent-tdd reset',
            ],
          'GREEN' => const [
              'agent-tdd verify-green',
              'agent-tdd status',
              'agent-tdd reset',
            ],
          'REFACTOR' => const [
              'agent-tdd verify-refactor',
              'agent-tdd status',
              'agent-tdd reset',
            ],
          _ => const [
              'agent-tdd next',
              'agent-tdd specs',
              'agent-tdd status',
              'agent-tdd reset',
            ],
        };

    final state = HarnessState(
      phase: phase,
      editablePatterns: editableFiles,
      readOnlyPatterns: readOnlyFiles,
      nextCommand: nextCommand,
      allowedCommands: defaultAllowed,
      metadata: {
        if (activeSpec != null) 'active_spec': activeSpec,
        if (issues != null) 'issues': issues,
      },
    );
    output.reportFailure(error: message, state: state);
  }

  Map<String, dynamic>? _activeSpecMap(int? id, String? title) {
    if (id == null || title == null) return null;
    return {'id': id, 'title': title};
  }
}
