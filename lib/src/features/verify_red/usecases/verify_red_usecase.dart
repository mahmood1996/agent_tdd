import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/config_store.dart';
import '../../../core/data/snapshot_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state_extensions.dart';
import '../../../core/services/git_client.dart';
import '../../../core/services/test_run_verifications.dart';

final class VerifyRedResult {
  final bool success;
  final HarnessState state;
  final TddConfig? config;
  final String message;

  const VerifyRedResult({
    required this.success,
    required this.state,
    this.config,
    required this.message,
  });
}

final class VerifyRedUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;
  final SnapshotStore snapshotStore;
  final TestRunVerifications testRunVerifications;
  final GitClient gitClient;

  VerifyRedUseCase({
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
        testRunVerifications =
            testRunVerifications ?? TestRunVerifications(projectDir),
        gitClient = gitClient ?? GitClient(projectDir: projectDir);

  Future<VerifyRedResult> execute() async {
    final state = await stateStore.harnessState();
    if (!state.isRed) {
      final msg =
          'verify-red can only be run during RED phase (Current phase: ${state.phase}).';
      return VerifyRedResult(
        success: false,
        state: state,
        message: msg,
      );
    }

    final config = await configStore.config();
    TestRunVerification? verification;

    await testRunVerifications.verifyRed((v) => verification = v);
    final ver = verification!;

    if (!ver.isValid) {
      return VerifyRedResult(
        success: false,
        state: state,
        config: config,
        message: ver.message,
      );
    }

    if (ver.phase == 'ALREADY_PASSED') {
      final newState = TddHarnessState.alreadyPassed(
        activeSpecId: state.activeSpecId ?? 0,
        activeSpecTitle: state.activeSpecTitle ?? '',
        startedAt: state.startedAt,
      );
      await stateStore.saveState(newState);

      if (state.activeSpecId != null) {
        await specStore.updateSpecStatus(state.activeSpecId!, 'already_passed');
      }

      return VerifyRedResult(
        success: true,
        state: newState,
        config: config,
        message:
            'Test PASSED! Spec requirement is already satisfied in production code.',
      );
    }

    final snapshot = await snapshotStore.capture(config.testFiles);
    await snapshotStore.save(snapshot);

    final newState = TddHarnessState.green(
      activeSpecId: state.activeSpecId ?? 0,
      activeSpecTitle: state.activeSpecTitle ?? '',
      startedAt: state.startedAt,
    );
    await stateStore.saveState(newState);

    if (state.activeSpecId != null) {
      await specStore.updateSpecStatus(state.activeSpecId!, 'green');
    }

    if (config.gitCommit) {
      await gitClient.commit(
          '🔴 RED: Spec #${state.activeSpecId} ${state.activeSpecTitle}');
    }

    return VerifyRedResult(
      success: true,
      state: newState,
      config: config,
      message: 'RED state verified! Phase advanced to GREEN.',
    );
  }
}
