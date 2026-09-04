import '../../../core/data/config_store.dart';
import '../../../core/data/snapshot_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/data/tdd_cycle.dart';
import '../../../core/domain/tdd_state.dart';
import '../../../core/services/git_client.dart';

final class CompleteCycleResult {
  final bool success;
  final TddState currentState;
  final int? completedSpecId;
  final String? completedSpecTitle;
  final Map<String, dynamic> summary;
  final String message;

  const CompleteCycleResult({
    required this.success,
    required this.currentState,
    this.completedSpecId,
    this.completedSpecTitle,
    required this.summary,
    required this.message,
  });
}

final class CompleteCycleUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final TddCycle tddCycle;
  final SnapshotStore snapshotStore;
  final GitClient gitClient;

  CompleteCycleUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    TddCycle? tddCycle,
    SnapshotStore? snapshotStore,
    GitClient? gitClient,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir),
        snapshotStore = snapshotStore ?? SnapshotStore(projectDir: projectDir),
        gitClient = gitClient ?? GitClient(projectDir: projectDir);

  Future<CompleteCycleResult> execute() async {
    final state = await tddCycle.savedTddState();
    final isAlreadyPassed = state.phase == TddPhase.alreadyPassed;

    if (state.phase != TddPhase.refactor && !isAlreadyPassed) {
      final msg =
          'complete can only be run after verifying REFACTOR phase (Current phase: ${state.phase.name.toUpperCase()}). Run verify-refactor first.';
      final summary = await specStore.summary();
      return CompleteCycleResult(
        success: false,
        currentState: state,
        summary: summary,
        message: msg,
      );
    }

    final activeId = state.activeSpecId;
    final activeTitle = state.activeSpecTitle;
    final config = await configStore.config();

    if (config.gitCommit) {
      final commitMsg = isAlreadyPassed
          ? '🎉 DONE (spec-$activeId): $activeTitle (already satisfied)'
          : '🎉 DONE (spec-$activeId): $activeTitle';
      await gitClient.commit(commitMsg);
    }

    if (activeId != null) {
      await specStore.updateSpecStatus(activeId, 'done');
    }

    await snapshotStore.delete();
    await tddCycle.reset();

    final summary = await specStore.summary();
    final resetState = await tddCycle.savedTddState();

    final messageStr = isAlreadyPassed
        ? 'Spec #$activeId was already satisfied and marked DONE! Run "agent-tdd next" to pick up the next pending spec item.'
        : 'Spec #$activeId marked DONE! Run "agent-tdd next" to pick up the next pending spec item.';

    return CompleteCycleResult(
      success: true,
      currentState: resetState,
      completedSpecId: activeId,
      completedSpecTitle: activeTitle,
      summary: summary,
      message: messageStr,
    );
  }
}


