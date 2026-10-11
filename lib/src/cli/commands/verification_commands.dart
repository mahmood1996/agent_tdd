import '../../core/data/config_store.dart';
import '../../core/data/tdd_state_store.dart';
import 'package:tdd_spec_store/tdd_spec_store.dart';
import '../../core/domain/tdd_state.dart';
import '../../core/services/analyzer.dart';
import '../../core/services/git_client.dart';
import '../../core/services/test_run_verifications.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/verify_green/usecases/verify_green_usecase.dart';
import '../../features/verify_red/usecases/verify_red_usecase.dart';
import '../../features/verify_refactor/usecases/verify_refactor_usecase.dart';
import '../presenter/verification_presenter.dart';

final class VerificationCommands {
  final String projectDir;
  final ConfigStore configStore;
  final TddSpecStore specStore;
  final TddStateStore stateStore;
  final TestRunVerifications testRunVerifications;
  final Analyzer analyzer;
  final GitClient gitClient;
  final VerificationPresenter presenter;

  const VerificationCommands({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    required this.stateStore,
    required this.testRunVerifications,
    required this.analyzer,
    required this.gitClient,
    this.presenter = const VerificationPresenter(),
  });

  Future<void> verifyRed() async {
    final useCase = VerifyRedUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
      testRunVerifications: testRunVerifications,
      gitClient: gitClient,
    );
    final res = await useCase.execute();

    if (!res.success) {
      final config = res.config ?? await configStore.config();
      presenter.renderVerifyRedFailure(res, config);
      return;
    }

    final state = res.state;
    if (state.phase == TddPhase.alreadyPassed) {
      final completeUseCase = CompleteCycleUseCase(
        projectDir: projectDir,
        configStore: configStore,
        specStore: specStore,
        stateStore: stateStore,
        gitClient: gitClient,
      );
      final completeRes = await completeUseCase.execute();
      presenter.renderVerifyRedAlreadyPassed(res, completeRes);
      return;
    }

    presenter.renderVerifyRedSuccess(res);
  }

  Future<void> verifyGreen() async {
    final useCase = VerifyGreenUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      stateStore: stateStore,
      testRunVerifications: testRunVerifications,
      gitClient: gitClient,
    );
    final res = await useCase.execute();
    presenter.renderVerifyGreen(res);
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
    final config = res.config ?? await configStore.config();
    presenter.renderVerifyRefactor(res, config);
  }
}
