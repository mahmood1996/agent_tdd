import 'dart:io';

import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:agent_tdd/agent_tdd.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

class MockGitClient extends GitClient {
  String? lastCommitMessage;

  MockGitClient({required String projectDir}) : super(projectDir: projectDir);

  @override
  Future<bool> commit(String message) async {
    lastCommitMessage = message;
    return true;
  }
}

void main() {
  final harness = BaseTest()..setUpBase('complete_cycle_usecase_test_');

  group('CompleteCycleUseCase Behavioral Solitary Unit Tests', () {
    test('execute fails when called outside REFACTOR phase', () async {
      final useCase = CompleteCycleUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message,
          contains('complete can only be run after verifying REFACTOR phase'));
    });

    test(
        'execute completes active spec, deletes snapshot, resets cycle to IDLE, and commits git',
        () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      await specStore.updateSpecStatus(1, 'refactor');

      final cycle = TddCycle(projectDir: harness.tempDir.path);
      await cycle.save(TddState(
        phase: TddPhase.refactor,
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
        startedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ));

      final captureSnapshot = CaptureSnapshot(
        fileIndex: DiskFileIndex(baseDir: harness.tempDir.path),
        snapshotStore: FileSnapshotStore(
          path: p.join(harness.tempDir.path, TddConstants.snapshotFileName),
        ),
      );
      await captureSnapshot('test/**/*.dart');

      final snapshotFile =
          File(p.join(harness.tempDir.path, TddConstants.snapshotFileName));
      expect(snapshotFile.existsSync(), isTrue);

      final mockGit = MockGitClient(projectDir: harness.tempDir.path);

      final useCase = CompleteCycleUseCase(
        projectDir: harness.tempDir.path,
        gitClient: mockGit,
      );

      final res = await useCase.execute();

      expect(res.success, isTrue);
      expect(res.completedSpecId, equals(1));
      expect(res.completedSpecTitle, equals('Spec 1'));
      expect(res.currentState.phase, equals(TddPhase.idle));
      expect(snapshotFile.existsSync(), isFalse);
      expect(mockGit.lastCommitMessage, contains('🎉 DONE (spec-1): Spec 1'));

      final updatedSpec = await specStore.activeSpec();
      expect(updatedSpec, isNull);

      final allSpecs = await specStore.specs();
      expect(allSpecs.first.status, equals('done'));
    });

    test('execute completes active spec when phase is TddPhase.alreadyPassed',
        () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      await specStore.updateSpecStatus(1, 'already_passed');

      final cycle = TddCycle(projectDir: harness.tempDir.path);
      await cycle.save(TddState(
        phase: TddPhase.alreadyPassed,
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
        startedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ));

      final mockGit = MockGitClient(projectDir: harness.tempDir.path);

      final useCase = CompleteCycleUseCase(
        projectDir: harness.tempDir.path,
        gitClient: mockGit,
      );

      final res = await useCase.execute();

      expect(res.success, isTrue);
      expect(res.completedSpecId, equals(1));
      expect(res.currentState.phase, equals(TddPhase.idle));
      expect(mockGit.lastCommitMessage,
          contains('🎉 DONE (spec-1): Spec 1 (already satisfied)'));

      final allSpecs = await specStore.specs();
      expect(allSpecs.first.status, equals('done'));
    });
  });
}
