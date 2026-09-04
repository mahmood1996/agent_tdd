import '../../core/data/config_store.dart';
import '../../core/data/spec_store.dart';
import '../../features/init/usecases/init_harness_usecase.dart';
import '../presenter/init_presenter.dart';

final class InitCommand {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final InitPresenter presenter;

  const InitCommand({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    this.presenter = const InitPresenter(),
  });

  Future<void> execute({String? runnerPreset}) async {
    final useCase = InitHarnessUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
    );
    final res = await useCase.execute(runnerPreset: runnerPreset);
    presenter.renderInit(res);
  }
}
