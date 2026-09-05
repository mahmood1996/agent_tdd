import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

class MockTestRunVerifications extends TestRunVerifications {
  TestRunVerification mockVerification;

  MockTestRunVerifications({
    required String projectDir,
    required this.mockVerification,
  }) : super(projectDir);

  @override
  Future<void> verifyRed(
      void Function(TestRunVerification ver) onFinished) async {
    onFinished(mockVerification);
  }

  @override
  Future<void> verifyGreen(
      void Function(TestRunVerification ver) onFinished) async {
    onFinished(mockVerification);
  }

  @override
  Future<void> verifyRefactor(
      void Function(TestRunVerification ver) onFinished) async {
    onFinished(mockVerification);
  }
}

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
  final harness = BaseTest()..setUpBase('verify_green_usecase_test_');

  group('VerifyGreenUseCase Behavioral Solitary Unit Tests', () {
    test('execute fails when executed outside GREEN phase', () async {
      final useCase = VerifyGreenUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message, contains('verify-green can only be run during GREEN phase'));
    });

    test('execute detects FREEZE VIOLATION when test files are modified during GREEN phase', () async {
      harness.createFile('pubspec.yaml', 'name: my_app\n');
      final testFile = harness.createFile('test/sample_test.dart', 'void main() {}');

      final snapshotStore = SnapshotStore(projectDir: harness.tempDir.path);
      final snapshot = await snapshotStore.capture('test/**/*.dart');
      await snapshotStore.save(snapshot);

      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.green(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      testFile.writeAsStringSync('void main() { print("modified!"); }');

      final useCase = VerifyGreenUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message, contains('FREEZE VIOLATION DETECTED!'));
      expect(res.violations, isNotEmpty);
    });

    test('execute fails if tests are still failing during GREEN phase', () async {
      harness.createFile('pubspec.yaml', 'name: my_app\n');
      harness.createFile('test/sample_test.dart', 'void main() {}');

      final snapshotStore = SnapshotStore(projectDir: harness.tempDir.path);
      final snapshot = await snapshotStore.capture('test/**/*.dart');
      await snapshotStore.save(snapshot);

      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.green(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: false,
          phase: 'GREEN',
          message: 'Tests failed! GREEN phase requires ALL tests to pass.',
          result: ExecutableProcessResult(
            exitCode: 1,
            stdout: '1 test failed',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );

      final useCase = VerifyGreenUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
      );

      final res = await useCase.execute();
      expect(res.success, isFalse);
      expect(res.message, contains('Tests failed!'));
    });

    test('execute succeeds when freeze intact & tests pass, advances to REFACTOR phase, and commits git', () async {
      harness.createFile('pubspec.yaml', 'name: my_app\n');
      harness.createFile('test/sample_test.dart', 'void main() {}');

      final snapshotStore = SnapshotStore(projectDir: harness.tempDir.path);
      final snapshot = await snapshotStore.capture('test/**/*.dart');
      await snapshotStore.save(snapshot);

      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');

      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.green(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: true,
          phase: 'GREEN',
          message: '100% of tests passed! GREEN state verified.',
          result: ExecutableProcessResult(
            exitCode: 0,
            stdout: 'All 5 tests passed',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );
      final mockGit = MockGitClient(projectDir: harness.tempDir.path);

      final useCase = VerifyGreenUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
        gitClient: mockGit,
      );

      final res = await useCase.execute();

      expect(res.success, isTrue);
      expect(res.state.isRefactor, isTrue);
      expect(res.message, contains('GREEN state verified! Phase advanced to REFACTOR.'));
      expect(mockGit.lastCommitMessage, contains('🟢 GREEN: Spec #1 Spec 1'));

      final updatedSpec = await specStore.activeSpec();
      expect(updatedSpec?.status, equals('refactor'));
    });
  });
}
