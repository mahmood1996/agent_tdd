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

class MockAnalyzer extends Analyzer {
  AnalysisResult mockResult;

  MockAnalyzer({
    required String projectDir,
    required this.mockResult,
  }) : super(projectDir: projectDir);

  @override
  Future<AnalysisResult> analysisResult() async => mockResult;
}

void main() {
  final harness = BaseTest()..setUpBase('verify_refactor_usecase_test_');

  group('VerifyRefactorUseCase Behavioral Solitary Unit Tests', () {
    test('execute fails when executed outside REFACTOR phase', () async {
      final useCase = VerifyRefactorUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.success, isFalse);
      expect(res.message,
          contains('verify-refactor can only be run during REFACTOR phase'));
    });

    test('execute fails if tests regress during refactoring', () async {
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.refactor(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: false,
          phase: 'REFACTOR',
          message: 'Tests failed! REFACTOR phase requires ALL tests to pass.',
          result: ExecutableProcessResult(
            exitCode: 1,
            stdout: 'FAIL',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );

      final useCase = VerifyRefactorUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
      );

      final res = await useCase.execute();
      expect(res.success, isFalse);
      expect(res.message,
          contains('Refactor broken! Tests failed after refactoring.'));
    });

    test('execute fails if static analysis detects issues', () async {
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.refactor(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: true,
          phase: 'REFACTOR',
          message: '100% of tests passed! REFACTOR state verified.',
          result: ExecutableProcessResult(
            exitCode: 0,
            stdout: 'Pass',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );

      final mockAnalyzer = MockAnalyzer(
        projectDir: harness.tempDir.path,
        mockResult: const AnalysisResult(
          isClean: false,
          issues: [
            AnalysisIssue(
                file: 'lib/main.dart',
                line: 10,
                column: 2,
                severity: 'warning',
                message: 'Unused import'),
          ],
          rawResult: ExecutableProcessResult(
              exitCode: 1, stdout: 'warning', stderr: '', durationMs: 10),
        ),
      );

      final useCase = VerifyRefactorUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
        analyzer: mockAnalyzer,
      );

      final res = await useCase.execute();
      expect(res.success, isFalse);
      expect(res.message,
          contains('Static Analysis issues detected (1 issue(s)).'));
      expect(res.analysisIssues.length, equals(1));
    });

    test('execute succeeds when 100% tests pass and static analysis is clean',
        () async {
      final store = FileStateStore(projectDir: harness.tempDir.path);
      await store.saveState(TddHarnessState.refactor(
        activeSpecId: 1,
        activeSpecTitle: 'Spec 1',
      ));

      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: true,
          phase: 'REFACTOR',
          message: '100% of tests passed! REFACTOR state verified.',
          result: ExecutableProcessResult(
            exitCode: 0,
            stdout: 'All tests passed',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );

      final mockAnalyzer = MockAnalyzer(
        projectDir: harness.tempDir.path,
        mockResult: const AnalysisResult(
          isClean: true,
          issues: [],
          rawResult: ExecutableProcessResult(
              exitCode: 0, stdout: 'No issues', stderr: '', durationMs: 10),
        ),
      );

      final useCase = VerifyRefactorUseCase(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
        analyzer: mockAnalyzer,
      );

      final res = await useCase.execute();
      expect(res.success, isTrue);
      expect(
          res.message,
          contains(
              'Refactor phase verified! 100% tests passed, 0 analysis warnings/errors.'));
    });
  });
}
