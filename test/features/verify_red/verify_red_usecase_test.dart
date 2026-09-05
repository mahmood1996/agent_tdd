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
  final harness = BaseTest()..setUpBase('verify_red_usecase_test_');

  group('VerifyRedUseCase Behavioral Solitary Unit Tests', () {
    test('execute fails when executed outside RED phase (e.g. IDLE)', () async {
      final useCase = VerifyRedUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message, contains('verify-red can only be run during RED phase'));
    });

    test('execute transitions to alreadyPassed phase when tests pass during RED phase', () async {
      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.red(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: true,
          phase: 'ALREADY_PASSED',
          message:
              'Tests PASSED! Spec requirement is already satisfied in production code.',
          result: ExecutableProcessResult(
            exitCode: 0,
            stdout: 'All tests passed',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );

      final useCase = VerifyRedUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
      );

      final res = await useCase.execute();
      expect(res.success, isTrue);
      expect(res.state.isAlreadyPassed, isTrue);
      expect(res.message, contains('Test PASSED! Spec requirement is already satisfied'));

      final updatedSpec = await specStore.activeSpec();
      expect(updatedSpec?.status, equals('already_passed'));
    });

    test('execute succeeds on test failure, advances to GREEN phase, and triggers git commit', () async {
      harness.createFile('pubspec.yaml', 'name: my_app\n');
      harness.createFile('test/sample_test.dart', 'void main() { throw Exception("fail"); }');

      final specStore = SpecStore(projectDir: harness.tempDir.path);
      await specStore.addSpec('Spec 1');
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.red(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: true,
          phase: 'RED',
          message:
              'Test failed as expected on an assertion failure. RED state verified!',
          result: ExecutableProcessResult(
            exitCode: 1,
            stdout: 'FAIL: Expected true but got false',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );
      final mockGit = MockGitClient(projectDir: harness.tempDir.path);

      final useCase = VerifyRedUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
        gitClient: mockGit,
      );

      final res = await useCase.execute();

      expect(res.success, isTrue);
      expect(res.state.isGreen, isTrue);
      expect(res.message, contains('RED state verified! Phase advanced to GREEN.'));
      expect(mockGit.lastCommitMessage, contains('🔴 RED: Spec #1 Spec 1'));

      final updatedSpec = await specStore.activeSpec();
      expect(updatedSpec?.status, equals('green'));
    });
  });
}
