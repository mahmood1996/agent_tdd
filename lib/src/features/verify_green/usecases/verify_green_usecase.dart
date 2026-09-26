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

final class VerifyGreenResult {
  final bool success;
  final TddState state;
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
  final TddCycle tddCycle;
  final GitClient gitClient;
  final TestRunVerifications testRunVerifications;
  final ParameterizedUsecase<List<String>, String> integrityViolations;

  VerifyGreenUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    TddCycle? tddCycle,
    TestRunVerifications? testRunVerifications,
    ParameterizedUsecase<List<String>, String>? integrityViolations,
    GitClient? gitClient,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir),
        integrityViolations = integrityViolations ??
            IntegrityViolations(
              fileIndex: DiskFileIndex(baseDir: projectDir),
              snapshotStore: FileSnapshotStore(
                path: p.join(projectDir, TddConstants.snapshotFileName),
              ),
            ),
        testRunVerifications = testRunVerifications ??
            TestRunVerifications(projectDir, configStore: configStore),
        gitClient = gitClient ?? GitClient(projectDir: projectDir);

  Future<VerifyGreenResult> execute() async {
    final state = await tddCycle.savedTddState();
    if (state.phase != TddPhase.green) {
      final msg =
          'verify-green can only be run during GREEN phase (Current phase: ${state.phase.name.toUpperCase()}).';
      return VerifyGreenResult(
        success: false,
        state: state,
        message: msg,
      );
    }

    final config = await configStore.config();
    final violations = await integrityViolations(config.testFiles);
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

    final newState = state.copyWith(
      phase: TddPhase.refactor,
      lastUpdated: DateTime.now(),
    );
    await tddCycle.save(newState);

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
