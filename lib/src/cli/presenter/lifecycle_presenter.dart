import '../../core/domain/tdd_state.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/next/usecases/start_next_cycle_usecase.dart';
import '../../features/reset/usecases/reset_cycle_usecase.dart';
import '../../features/status/usecases/get_status_usecase.dart';
import '../logger.dart';
import 'base_presenter.dart';

final class LifecyclePresenter extends BasePresenter {
  const LifecyclePresenter();

  void renderNext(StartNextCycleResult res) {
    if (!res.success) {
      if (Logger.jsonOutput) {
        Logger.agentJson(
          success: false,
          phase: res.currentState.phase.name.toUpperCase(),
          activeSpec: activeSpecMap(
              res.currentState.activeSpecId, res.currentState.activeSpecTitle),
          instructionsForAgent: res.message,
        );
      } else {
        if (res.currentState.phase != TddPhase.idle) {
          Logger.error(res.message);
        } else {
          Logger.warning(res.message);
        }
      }
      return;
    }

    final pendingSpec = res.activeSpec!;
    final config = res.config!;

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'RED',
        activeSpec: pendingSpec.toJson(),
        allowedActions: allowedActionsMap(
          editableFiles: [config.testFiles],
          readOnlyFiles: [config.sourceFiles, 'specs.yaml', '.tddrc.yaml'],
          nextCommand: 'agent-tdd verify-red',
        ),
        instructionsForAgent:
            'Write a failing unit test in ${config.testFiles} for Spec #${pendingSpec.id} "${pendingSpec.title}". Production code is strictly READ-ONLY. DO NOT edit or modify production code under any circumstances during the RED phase (if your test passes, expand your test assertions in ${config.testFiles} to test unhandled requirements). Run "agent-tdd verify-red" when ready.',
      );
      return;
    }

    Logger.info('\n🎯 Active Spec #${pendingSpec.id}: "${pendingSpec.title}"');
    Logger.error('[TDD HARNESS] Phase: RED');
    Logger.info(
        '📝 Instructions: Write a failing unit test for Spec #${pendingSpec.id}.');
    Logger.warning(
        '⚠️  Production code (${config.sourceFiles}) is strictly READ-ONLY. Edit test files (${config.testFiles}) only.');
    Logger.info('👉 When done writing test, run "agent-tdd verify-red".');
  }

  void renderComplete(CompleteCycleResult res) {
    if (!res.success) {
      renderError(
          message: res.message, phase: res.currentState.phase.name.toUpperCase());
      return;
    }

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'IDLE',
        progress: res.summary,
        instructionsForAgent:
            'Spec #${res.completedSpecId} marked DONE! Run "agent-tdd next" to pick up the next pending spec item.',
      );
      return;
    }

    Logger.info(
        '📊 Backlog Progress: ${res.summary['completed']}/${res.summary['total']} completed (${res.summary['percentage']}%).');
    Logger.info('👉 Run "agent-tdd next" to start the next spec item.');
  }

  void renderStatus(GetStatusResult res, String projectDir) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: res.state.phase.name.toUpperCase(),
        activeSpec:
            activeSpecMap(res.state.activeSpecId, res.state.activeSpecTitle),
        progress: res.summary,
        instructionsForAgent:
            'Current TDD phase: ${res.state.phase.name.toUpperCase()}.',
      );
      return;
    }

    Logger.info('--------------------------------------------------');
    Logger.info('🤖 agent-tdd Status Dashboard');
    Logger.info('--------------------------------------------------');
    Logger.info('Project Dir : $projectDir');
    Logger.info(
        'Preset      : ${res.config.runner} (Test cmd: "${res.config.testCommand}")');
    Logger.info('Phase       : ${res.state.phase.name.toUpperCase()}');
    if (res.state.activeSpecId != null) {
      Logger.info(
          'Active Spec : #${res.state.activeSpecId} "${res.state.activeSpecTitle}"');
    }
    Logger.info(
        'Progress    : ${res.summary['completed']}/${res.summary['total']} completed (${res.summary['percentage']}%)');
    Logger.info('--------------------------------------------------');
  }

  void renderReset(ResetCycleResult res) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: res.success,
        phase: 'IDLE',
        instructionsForAgent: 'TDD state machine reset to IDLE.',
      );
      return;
    }

    Logger.success('Reset agent-tdd state to IDLE.');
  }
}
