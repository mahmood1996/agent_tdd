import '../data/config_store.dart';
import '../domain/executable_process_result.dart';
import 'processes.dart';

final class TestRunVerification {
  final bool isValid;
  final String phase; // RED, GREEN, or ALREADY_PASSED
  final String message;
  final ExecutableProcessResult result;

  const TestRunVerification({
    required this.isValid,
    required this.phase,
    required this.message,
    required this.result,
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
        .process(config.testCommand)
        .execute(onFinished: (res) => result = res);

    onFinished(_redVerification(result!));
  }

  Future<void> verifyGreen(
    void Function(TestRunVerification ver) onFinished,
  ) async {
    final config = await configStore.config();
    ExecutableProcessResult? result;

    await processes
        .process(config.testCommand)
        .execute(onFinished: (res) => result = res);

    onFinished(_greenVerification(result!));
  }

  Future<void> verifyRefactor(
    void Function(TestRunVerification ver) onFinished,
  ) async {
    final config = await configStore.config();
    ExecutableProcessResult? result;

    await processes
        .process(config.testCommand)
        .execute(onFinished: (res) => result = res);

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
        result: result,
      );
    }

    if (result.isSuccess) {
      return TestRunVerification(
        isValid: true,
        phase: 'ALREADY_PASSED',
        message:
            'Tests PASSED! Spec requirement is already satisfied in production code.',
        result: result,
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
        result: result,
      );
    }

    return TestRunVerification(
      isValid: true,
      phase: 'RED',
      message:
          'Test run failed (exit code ${result.exitCode}). RED state verified.',
      result: result,
    );
  }

  TestRunVerification _greenVerification(ExecutableProcessResult result) {
    return result.isSuccess
        ? TestRunVerification(
            isValid: true,
            phase: 'GREEN',
            message: '100% of tests passed! GREEN state verified.',
            result: result,
          )
        : TestRunVerification(
            isValid: false,
            phase: 'GREEN',
            message:
                'Tests failed! GREEN phase requires ALL tests to pass.\nOutput:\n${result.combinedOutput}',
            result: result,
          );
  }

  TestRunVerification _refactorVerification(ExecutableProcessResult result) {
    return result.isSuccess
        ? TestRunVerification(
            isValid: true,
            phase: 'REFACTOR',
            message: '100% of tests passed! REFACTOR state verified.',
            result: result,
          )
        : TestRunVerification(
            isValid: false,
            phase: 'REFACTOR',
            message:
                'Tests failed! REFACTOR phase requires ALL tests to pass.\nOutput:\n${result.combinedOutput}',
            result: result,
          );
  }
}
