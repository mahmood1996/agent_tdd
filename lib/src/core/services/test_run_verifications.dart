import '../data/config_store.dart';
import 'package:processes/processes.dart';

final class TestRunVerification {
  final bool isValid;
  final String phase; // RED, GREEN, or ALREADY_PASSED
  final String message;

  const TestRunVerification({
    required this.isValid,
    required this.phase,
    required this.message,
  });
}

class TestRunVerifications {
  final String projectDir;
  final ConfigStore configStore;
  final Processes processes;

  TestRunVerifications(
    this.projectDir, {
    ConfigStore? configStore,
    Processes? processes,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        processes = processes ?? Processes(projectDir);

  Future<void> verifyRed(
    void Function(TestRunVerification ver) onFinished,
  ) async {
    final config = await configStore.config();
    ExecutableProcessResult? result;

    await processes
        .process(config.testCommand, onFinished: (res) => result = res)
        .execute();

    onFinished(_redVerification(result!));
  }

  Future<void> verifyGreen(
    void Function(TestRunVerification ver) onFinished,
  ) async {
    final config = await configStore.config();
    ExecutableProcessResult? result;

    await processes
        .process(config.testCommand, onFinished: (res) => result = res)
        .execute();

    onFinished(_greenVerification(result!));
  }

  Future<void> verifyRefactor(
    void Function(TestRunVerification ver) onFinished,
  ) async {
    final config = await configStore.config();
    ExecutableProcessResult? result;

    await processes
        .process(config.testCommand, onFinished: (res) => result = res)
        .execute();

    onFinished(_refactorVerification(result!));
  }

  TestRunVerification _redVerification(ExecutableProcessResult result) {
    final output = result.combinedOutput;

    // Check if process crashed due to syntax/compilation error before running tests
    final hasSyntaxError = output.contains('SyntaxError') ||
        output.contains('Compilation failed') ||
        output.contains('Error: Could not resolve') ||
        output.contains('ParseError');

    if (hasSyntaxError) {
      return TestRunVerification(
        isValid: false,
        phase: 'RED',
        message:
            'Compilation/Syntax error detected! Fix syntax errors before verifying RED state.\nOutput:\n$output',
      );
    }

    if (result.isSuccess) {
      return TestRunVerification(
        isValid: true,
        phase: 'ALREADY_PASSED',
        message:
            'Tests PASSED! Spec requirement is already satisfied in production code.',
      );
    }

    // Check for common test failure keywords
    final hasAssertionFailure = output.contains('FAILED') ||
        output.contains('FAIL') ||
        output.contains('AssertionError') ||
        output.contains('Expected') ||
        output.contains('expect') ||
        output.contains('FAILURES!') ||
        output.contains('failed');

    if (hasAssertionFailure) {
      return TestRunVerification(
        isValid: true,
        phase: 'RED',
        message:
            'Test failed as expected on an assertion failure. RED state verified!',
      );
    }

    return TestRunVerification(
      isValid: true,
      phase: 'RED',
      message:
          'Test run failed (exit code ${result.exitCode}). RED state verified.',
    );
  }

  TestRunVerification _greenVerification(ExecutableProcessResult result) {
    return result.isSuccess
        ? TestRunVerification(
            isValid: true,
            phase: 'GREEN',
            message: '100% of tests passed! GREEN state verified.',
          )
        : TestRunVerification(
            isValid: false,
            phase: 'GREEN',
            message:
                'Tests failed! GREEN phase requires ALL tests to pass.\nOutput:\n${result.combinedOutput}',
          );
  }

  TestRunVerification _refactorVerification(ExecutableProcessResult result) {
    return result.isSuccess
        ? TestRunVerification(
            isValid: true,
            phase: 'REFACTOR',
            message: '100% of tests passed! REFACTOR state verified.',
          )
        : TestRunVerification(
            isValid: false,
            phase: 'REFACTOR',
            message:
                'Tests failed! REFACTOR phase requires ALL tests to pass.\nOutput:\n${result.combinedOutput}',
          );
  }
}
