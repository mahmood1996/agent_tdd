import '../../features/init/usecases/init_harness_usecase.dart';
import '../logger.dart';
import 'base_presenter.dart';

final class InitPresenter extends BasePresenter {
  const InitPresenter();

  void renderInit(InitHarnessResult res) {
    if (!res.success) {
      renderError(message: res.message, phase: 'IDLE');
      return;
    }

    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'IDLE',
        instructionsForAgent:
            'agent-tdd initialized successfully with preset "${res.config.runner}". Add specs to specs.yaml or specs.md, then run "agent-tdd next".',
      );
      return;
    }

    Logger.success(res.message);
    Logger.info(
        '📌 Preset: ${res.config.runner} (Test command: "${res.config.testCommand}")');
    Logger.info('📄 Created .tddrc.yaml and specs.yaml.');
    Logger.info('👉 Run "agent-tdd next" to start your first TDD cycle.');
  }
}
