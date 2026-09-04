import '../../core/domain/tdd_config.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/verify_green/usecases/verify_green_usecase.dart';
import '../../features/verify_red/usecases/verify_red_usecase.dart';
import '../../features/verify_refactor/usecases/verify_refactor_usecase.dart';
import '../logger.dart';
import 'base_presenter.dart';

final class VerificationPresenter extends BasePresenter {
  const VerificationPresenter();

  void renderVerifyRedFailure(VerifyRedResult res, TddConfig config) {
    renderError(
      message: res.message,
      phase: res.state.phase.name.toUpperCase(),
      activeSpec: activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
      allowedActions: allowedActionsMap(
        editableFiles: [config.testFiles],
        readOnlyFiles: [config.sourceFiles, 'specs.yaml', '.tddrc.yaml'],
        nextCommand: 'agent-tdd verify-red',
      ),
    );
  }

  void renderVerifyRedAlreadyPassed(
    VerifyRedResult res,
    CompleteCycleResult completeRes,
  ) {
    final state = res.state;
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'IDLE',
        progress: completeRes.summary,
        allowedActions: {
          'next_command': 'agent-tdd next',
        },
        instructionsForAgent:
            'Test PASSED! Spec #${state.activeSpecId} "${state.activeSpecTitle}" was already satisfied in existing production code. Cycle automatically completed! Run "agent-tdd next" to pick up the next pending spec.',
      );
      return;
    }

    Logger.success(
        '🎉 Test PASSED! Spec #${state.activeSpecId} "${state.activeSpecTitle}" is already satisfied in existing production code.');
    Logger.info(
        '📊 Backlog Progress: ${completeRes.summary['completed']}/${completeRes.summary['total']} completed (${completeRes.summary['percentage']}%).');
    Logger.info('👉 Run "agent-tdd next" to start the next spec item.');
  }

  void renderVerifyRedSuccess(VerifyRedResult res) {
    final config = res.config!;
    final state = res.state;

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'GREEN',
        activeSpec: activeSpecMap(state.activeSpecId, state.activeSpecTitle),
        allowedActions: allowedActionsMap(
          editableFiles: [config.sourceFiles],
          readOnlyFiles: [config.testFiles, 'specs.yaml', '.tddrc.yaml'],
          nextCommand: 'agent-tdd verify-green',
        ),
        instructionsForAgent:
            'Test failed as expected. Test files (${config.testFiles}) are cryptographically FROZEN. Write minimal production code in ${config.sourceFiles} to pass the test. Run "agent-tdd verify-green" when done.',
      );
      return;
    }

    Logger.warning('🔐 Test files (${config.testFiles}) are snapshot-locked.');
    Logger.success('[TDD HARNESS] Phase: GREEN');
    Logger.info(
        '📝 Instructions: Write minimal production code in ${config.sourceFiles} to make the test pass.');
    Logger.info('👉 Run "agent-tdd verify-green" when ready.');
  }

  void renderVerifyGreen(VerifyGreenResult res) {
    if (!res.success) {
      renderError(
        message: res.message,
        phase: res.state.phase.name.toUpperCase(),
        activeSpec:
            activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        issues: res.violations.isNotEmpty
            ? res.violations.map((v) => {'violation': v}).toList()
            : null,
      );
      return;
    }

    final config = res.config!;
    final state = res.state;

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'REFACTOR',
        activeSpec: activeSpecMap(state.activeSpecId, state.activeSpecTitle),
        allowedActions: allowedActionsMap(
          editableFiles: [config.sourceFiles, config.testFiles],
          readOnlyFiles: ['specs.yaml', '.tddrc.yaml'],
          nextCommand: 'agent-tdd verify-refactor',
        ),
        instructionsForAgent:
            '100% of tests passed! You are now in the REFACTOR phase. Clean up code/tests if needed, then run "agent-tdd verify-refactor".',
      );
      return;
    }

    Logger.info('[TDD HARNESS] Phase: REFACTOR');
    Logger.info(
        '📝 Instructions: Clean up code/tests. Run "agent-tdd verify-refactor" to run tests + static analysis.');
  }

  void renderVerifyRefactor(VerifyRefactorResult res, TddConfig config) {
    if (!res.success) {
      renderError(
        message: res.message,
        phase: 'REFACTOR',
        activeSpec:
            activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        issues: res.analysisIssues.isNotEmpty
            ? res.analysisIssues.map((i) => i.toJson()).toList()
            : null,
      );
      return;
    }

    final state = res.state;

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'REFACTOR',
        activeSpec: activeSpecMap(state.activeSpecId, state.activeSpecTitle),
        allowedActions: allowedActionsMap(
          editableFiles: [config.sourceFiles, config.testFiles],
          readOnlyFiles: ['specs.yaml', '.tddrc.yaml'],
          nextCommand: 'agent-tdd complete',
        ),
        instructionsForAgent:
            'Refactor phase verified! 100% tests passed, 0 analysis warnings/errors. Run "agent-tdd complete" to finish Spec #${state.activeSpecId}.',
      );
      return;
    }

    Logger.info('👉 Run "agent-tdd complete" to finish active spec cycle.');
  }
}
