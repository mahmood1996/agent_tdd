import '../../core/data/config_store.dart';
import '../../core/data/snapshot_store.dart';
import '../../core/data/spec_store.dart';
import '../../core/data/tdd_cycle.dart';
import '../../core/services/git_client.dart';
import '../../features/complete/usecases/complete_cycle_usecase.dart';
import '../../features/next/usecases/start_next_cycle_usecase.dart';
import '../../features/reset/usecases/reset_cycle_usecase.dart';
import '../../features/status/usecases/get_status_usecase.dart';
import '../presenter/lifecycle_presenter.dart';

final class LifecycleCommands {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final TddCycle tddCycle;
  final SnapshotStore snapshotStore;
  final GitClient gitClient;
  final LifecyclePresenter presenter;

  const LifecycleCommands({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    required this.tddCycle,
    required this.snapshotStore,
    required this.gitClient,
    this.presenter = const LifecyclePresenter(),
  });

  Future<void> next() async {
    final useCase = StartNextCycleUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      tddCycle: tddCycle,
    );
    final res = await useCase.execute();
    presenter.renderNext(res);
  }

  Future<void> complete() async {
    final useCase = CompleteCycleUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      tddCycle: tddCycle,
      snapshotStore: snapshotStore,
      gitClient: gitClient,
    );
    final res = await useCase.execute();
    presenter.renderComplete(res);
  }

  Future<void> status() async {
    final useCase = GetStatusUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
      tddCycle: tddCycle,
    );
    final res = await useCase.execute();
    presenter.renderStatus(res, projectDir);
  }

  Future<void> reset() async {
    final useCase = ResetCycleUseCase(
      projectDir: projectDir,
      snapshotStore: snapshotStore,
      tddCycle: tddCycle,
    );
    final res = await useCase.execute();
    presenter.renderReset(res);
  }
}
