import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('test_runner_test_');

  group('TestRunVerifications Solitary Unit Tests', () {
    test('verifyRed flags alreadyPassed if tests pass', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"All tests passed\\""',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyRed((v) => ver = v);
      expect(ver!.isValid, isTrue);
      expect(ver!.phase, equals('ALREADY_PASSED'));
      expect(
        ver!.message,
        contains('Tests PASSED! Spec requirement is already satisfied'),
      );
    });

    test('verifyRed succeeds on assertion failure', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"FAIL src/app.test.ts\\nAssertionError: expected false to be true\\" && exit 1"',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyRed((v) => ver = v);
      expect(ver!.isValid, isTrue);
      expect(ver!.message, contains('RED state verified'));
    });

    test('verifyGreen succeeds when all tests pass', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"10 passed\\""',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyGreen((v) => ver = v);
      expect(ver!.isValid, isTrue);
      expect(ver!.message, contains('GREEN state verified'));
    });

    test('verifyGreen fails when test fails', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"1 failed\\" && exit 1"',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyGreen((v) => ver = v);
      expect(ver!.isValid, isFalse);
      expect(ver!.message, contains('Tests failed!'));
    });

    test('verifyRefactor succeeds when all tests pass', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"10 passed\\""',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyRefactor((v) => ver = v);
      expect(ver!.isValid, isTrue);
      expect(ver!.phase, equals('REFACTOR'));
      expect(ver!.message, contains('REFACTOR state verified'));
    });

    test('verifyRefactor fails when test fails', () async {
      harness.createFile(
        '.tddrc.yaml',
        'test_command: "echo \\"1 failed\\" && exit 1"',
      );
      final verifications = TestRunVerifications(harness.tempDir.path);
      TestRunVerification? ver;
      await verifications.verifyRefactor((v) => ver = v);
      expect(ver!.isValid, isFalse);
      expect(ver!.phase, equals('REFACTOR'));
      expect(ver!.message, contains('Tests failed!'));
    });
  });
}
