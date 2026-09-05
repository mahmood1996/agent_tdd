import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../helpers/base_test_harness.dart';

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

class CliRunnerTestHarness extends BaseTest {}

void main() {
  final harness = CliRunnerTestHarness()..setUpBase('cli_runner_json_test_');

  group('CliRunner JSON Output Tests for All Commands', () {
    test('init outputs valid JSON', () async {
      harness.createFile('pubspec.yaml', 'name: test_app\n');
      final runner = CliRunner(projectDir: harness.tempDir.path);

      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('init', ['dart']),
      );
      expect(json['success'], isTrue);
      expect(json['phase'], equals('IDLE'));
      expect(json['allowed_actions']['allowed_commands'], equals(['agent-tdd next', 'agent-tdd specs', 'agent-tdd status', 'agent-tdd reset']));
      expect(
        json['instructions_for_agent'],
        contains('initialized successfully'),
      );
    });

    test('specs list outputs valid JSON', () async {
      harness.createFile('pubspec.yaml', 'name: test_app\n');
      final runner = CliRunner(projectDir: harness.tempDir.path);
      await runner.runCommand('init', ['dart']);

      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['list']),
      );
      expect(json['success'], isTrue);
      expect(json['phase'], equals('IDLE'));
      expect(json['progress'], isNotNull);
      expect(json['allowed_actions']['allowed_commands'], equals(['agent-tdd next', 'agent-tdd specs', 'agent-tdd status', 'agent-tdd reset']));
      expect(json['instructions_for_agent'], equals('Specs backlog listed.'));
    });

    test('specs add with missing title outputs error JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['add']),
      );
      expect(json['success'], isFalse);
      expect(json['instructions_for_agent'], contains('Missing spec title'));
    });

    test('specs add with title outputs success JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['add', 'New', 'Feature']),
      );
      expect(json['success'], isTrue);
      expect(json['active_spec'], isNotNull);
      expect(json['active_spec']['title'], equals('New Feature'));
    });

    test('specs import with missing file outputs error JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['import']),
      );
      expect(json['success'], isFalse);
      expect(json['instructions_for_agent'], contains('Missing file path'));
    });

    test('specs import with file outputs success JSON', () async {
      final mdFile = harness.createFile('backlog.md', '- [ ] Feature X\n');

      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['import', mdFile.path]),
      );
      expect(json['success'], isTrue);
      expect(json['instructions_for_agent'], contains('Imported specs from'));
    });

    test('specs with unknown subcommand outputs error JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('specs', ['invalid_sub']),
      );
      expect(json['success'], isFalse);
      expect(
        json['instructions_for_agent'],
        contains('Unknown specs subcommand'),
      );
    });

    test('next outputs valid JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      await CliRunner(projectDir: harness.tempDir.path)
          .runCommand('init', ['dart']);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('next'),
      );
      expect(json['success'], isTrue);
      expect(json['phase'], equals('RED'));
      expect(json['allowed_actions'], isNotNull);
      expect(json['allowed_actions']['allowed_commands'], equals(['agent-tdd verify-red', 'agent-tdd status', 'agent-tdd reset']));
    });

    test(
      'verify-red, verify-green, verify-refactor, complete, status, reset output valid JSON',
      () async {
        final runner = CliRunner(projectDir: harness.tempDir.path);
        await CliRunner(projectDir: harness.tempDir.path)
            .runCommand('init', ['dart']);

        final statusJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('status'),
        );
        expect(statusJson['success'], isTrue);
        expect(statusJson['phase'], equals('IDLE'));

        final resetJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('reset'),
        );
        expect(resetJson['success'], isTrue);
        expect(resetJson['phase'], equals('IDLE'));

        final completeJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('complete'),
        );
        expect(completeJson['success'], isFalse);

        final verifyRedJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('verify-red'),
        );
        expect(verifyRedJson['success'], isFalse);

        final verifyGreenJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('verify-green'),
        );
        expect(verifyGreenJson['success'], isFalse);

        final verifyRefactorJson = await BaseTest.captureJsonOutput(
          () => runner.runCommand('verify-refactor'),
        );
        expect(verifyRefactorJson['success'], isFalse);
      },
    );

    test('verify-red when tests pass auto-completes cycle to IDLE', () async {
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
      final runner = CliRunner(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
      );

      await CliRunner(projectDir: harness.tempDir.path).runCommand('init', ['dart']);
      await runner.runCommand('specs', ['add', 'Test Spec']);
      await runner.runCommand('next');

      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('verify-red'),
      );
      expect(json['success'], isTrue);
      expect(json['phase'], equals('IDLE'));
      expect(json['allowed_actions']['next_command'], equals('agent-tdd next'));
      expect(json['instructions_for_agent'], contains('Test PASSED!'));
    });

    test('verify-red syntax error in RED phase keeps state in RED', () async {
      final mockRunner = MockTestRunVerifications(
        projectDir: harness.tempDir.path,
        mockVerification: const TestRunVerification(
          isValid: false,
          phase: 'RED',
          message:
              'Compilation/Syntax error detected! Fix syntax errors before verifying RED state.',
          result: ExecutableProcessResult(
            exitCode: 1,
            stdout: 'SyntaxError: Unexpected token',
            stderr: '',
            durationMs: 50,
          ),
        ),
      );
      final runner = CliRunner(
        projectDir: harness.tempDir.path,
        testRunVerifications: mockRunner,
      );

      await CliRunner(projectDir: harness.tempDir.path).runCommand('init', ['dart']);
      await runner.runCommand('specs', ['add', 'Test Spec']);
      await runner.runCommand('next');

      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('verify-red'),
      );
      expect(json['success'], isFalse);
      expect(json['phase'], equals('RED'));
      expect(json['allowed_actions']['editable_files'], equals(['test/**/*_test.dart']));
      expect(json['allowed_actions']['read_only_files'], contains('lib/**/*.dart'));
    });

    test('unknown command outputs error JSON', () async {
      final runner = CliRunner(projectDir: harness.tempDir.path);
      final json = await BaseTest.captureJsonOutput(
        () => runner.runCommand('unknown_command'),
      );
      expect(json['success'], isFalse);
      expect(json['instructions_for_agent'], contains('Unknown command'));
    });
  });
}
