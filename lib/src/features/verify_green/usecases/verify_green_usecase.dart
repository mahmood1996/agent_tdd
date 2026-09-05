import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/config_store.dart';
import '../../../core/data/snapshot_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state_extensions.dart';
import '../../../core/services/git_client.dart';
import '../../../core/services/test_run_verifications.dart';

final class VerifyGreenResult {
  final bool success;
  final HarnessState state;
  final TddConfig? config;
  final List<String> violations;
  final String message;

  const VerifyGreenResult({
    required this.success,
    required this.state,
    this.config,
    this.violations = const [],
    required this.message,
  });
}

final class VerifyGreenUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;
  final SnapshotStore snapshotStore;
  final TestRunVerifications testRunVerifications;
  final GitClient gitClient;

  VerifyGreenUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    StateStore? stateStore,
    SnapshotStore? snapshotStore,
    TestRunVerifications? testRunVerifications,
    GitClient? gitClient,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir),
        snapshotStore = snapshotStore ?? SnapshotStore(projectDir: projectDir),
        testRunVerifications = testRunVerifications ??
            TestRunVerifications(projectDir, configStore: configStore),
        gitClient = gitClient ?? GitClient(projectDir: projectDir);

  Future<VerifyGreenResult> execute() async {
    final state = await stateStore.harnessState();
    if (!state.isGreen) {
      final msg =
          'verify-green can only be run during GREEN phase (Current phase: ${state.phase}).';
      return VerifyGreenResult(
        success: false,
        state: state,
        message: msg,
      );
    }

    final config = await configStore.config();
    final violations = await snapshotStore.verifyIntegrity(config.testFiles);
    if (violations.isNotEmpty) {
      final msg =
          'FREEZE VIOLATION DETECTED! Test files were modified during GREEN phase:\n${violations.join('\n')}';
      return VerifyGreenResult(
        success: false,
        state: state,
        config: config,
        violations: violations,
        message: msg,
      );
    }

    TestRunVerification? verification;
    await testRunVerifications.verifyGreen((v) => verification = v);
    final ver = verification!;

    if (!ver.isValid) {
      return VerifyGreenResult(
        success: false,
        state: state,
        config: config,
        message: ver.message,
      );
    }

    final newState = TddHarnessState.refactor(
      activeSpecId: state.activeSpecId ?? 0,
      activeSpecTitle: state.activeSpecTitle ?? '',
      startedAt: state.startedAt,
    );
    await stateStore.saveState(newState);

    if (state.activeSpecId != null) {
      await specStore.updateSpecStatus(state.activeSpecId!, 'refactor');
    }

    if (config.gitCommit) {
      await gitClient.commit(
          '🟢 GREEN: Spec #${state.activeSpecId} ${state.activeSpecTitle}');
    }

    return VerifyGreenResult(
      success: true,
      state: newState,
      config: config,
      message: 'GREEN state verified! Phase advanced to REFACTOR.',
    );
  }
}
