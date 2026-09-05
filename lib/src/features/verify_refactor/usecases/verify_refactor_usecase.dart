import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/config_store.dart';
import '../../../core/domain/analysis_issue.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state_extensions.dart';
import '../../../core/services/analyzer.dart';
import '../../../core/services/test_run_verifications.dart';

final class VerifyRefactorResult {
  final bool success;
  final HarnessState state;
  final TddConfig? config;
  final List<AnalysisIssue> analysisIssues;
  final String message;

  const VerifyRefactorResult({
    required this.success,
    required this.state,
    this.config,
    this.analysisIssues = const [],
    required this.message,
  });
}

final class VerifyRefactorUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final StateStore stateStore;
  final TestRunVerifications testRunVerifications;
  final Analyzer analyzer;

  VerifyRefactorUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    StateStore? stateStore,
    TestRunVerifications? testRunVerifications,
    Analyzer? analyzer,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir),
        testRunVerifications = testRunVerifications ??
            TestRunVerifications(projectDir, configStore: configStore),
        analyzer = analyzer ??
            Analyzer(projectDir: projectDir, configStore: configStore);

  Future<VerifyRefactorResult> execute() async {
    final state = await stateStore.harnessState();
    if (!state.isRefactor) {
      final msg =
          'verify-refactor can only be run during REFACTOR phase (Current phase: ${state.phase}).';
      return VerifyRefactorResult(
        success: false,
        state: state,
        message: msg,
      );
    }

    final config = await configStore.config();
    TestRunVerification? testVer;
    await testRunVerifications.verifyRefactor((v) => testVer = v);
    final ver = testVer!;

    if (!ver.isValid) {
      const msg = 'Refactor broken! Tests failed after refactoring.';
      return VerifyRefactorResult(
        success: false,
        state: state,
        config: config,
        message: msg,
      );
    }

    final analysisResult = await analyzer.analysisResult();
    if (!analysisResult.isClean) {
      final msg =
          'Static Analysis issues detected (${analysisResult.issues.length} issue(s)).';
      return VerifyRefactorResult(
        success: false,
        state: state,
        config: config,
        analysisIssues: analysisResult.issues,
        message: msg,
      );
    }

    return VerifyRefactorResult(
      success: true,
      state: state,
      config: config,
      analysisIssues: analysisResult.issues,
      message:
          'Refactor phase verified! 100% tests passed, 0 analysis warnings/errors. Run "agent-tdd complete" to finish Spec #${state.activeSpecId}.',
    );
  }
}
