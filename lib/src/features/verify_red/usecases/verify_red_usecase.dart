import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:usecase/usecase.dart';

import '../../../core/data/config_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_constants.dart';
import '../../../core/domain/tdd_state.dart';
import '../../../core/services/git_client.dart';
import '../../../core/services/test_run_verifications.dart';

final class VerifyRedResult {
  final bool success;
  final TddState state;
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
  final TddCycle tddCycle;
  final TestRunVerifications testRunVerifications;
  final ParameterizedUsecase<void, String> captureSnapshot;
  final GitClient gitClient;

  VerifyRedUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    TddCycle? tddCycle,
    TestRunVerifications? testRunVerifications,
    ParameterizedUsecase<void, String>? captureSnapshot,
    GitClient? gitClient,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir),
        captureSnapshot = captureSnapshot ??
            CaptureSnapshot(
              fileIndex: DiskFileIndex(baseDir: projectDir),
              snapshotStore: FileSnapshotStore(
                path: p.join(projectDir, TddConstants.snapshotFileName),
              ),
            ),
        testRunVerifications =
            testRunVerifications ?? TestRunVerifications(projectDir),
        gitClient = gitClient ?? GitClient(projectDir: projectDir);

  Future<VerifyRedResult> execute() async {
    final state = await tddCycle.savedTddState();
    if (state.phase != TddPhase.red) {
      final msg =
          'verify-red can only be run during RED phase (Current phase: ${state.phase.name.toUpperCase()}).';
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
      final newState = state.copyWith(
        phase: TddPhase.alreadyPassed,
        lastUpdated: DateTime.now(),
      );
      await tddCycle.save(newState);

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

    await captureSnapshot(config.testFiles);

    final newState = state.copyWith(
      phase: TddPhase.green,
      lastUpdated: DateTime.now(),
    );
    await tddCycle.save(newState);

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
