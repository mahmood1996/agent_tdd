import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('process_runner_test_');

  group('Processes & ExecutableProcess Solitary Unit Tests', () {
    test('execute runs successful command and invokes onFinished callback', () async {
      final processes = Processes(harness.tempDir.path);
      ExecutableProcessResult? res;

      await processes.process('echo "hello world"').execute(
        onFinished: (result) {
          res = result;
        },
      );

      expect(res, isNotNull);
      expect(res!.exitCode, equals(0));
      expect(res!.isSuccess, isTrue);
      expect(res!.stdout.trim(), equals('hello world'));
      expect(res!.durationMs, greaterThanOrEqualTo(0));
    });

    test('execute captures non-zero exit code on failure', () async {
      final processes = Processes(harness.tempDir.path);
      ExecutableProcessResult? res;

      await processes.process('exit 1').execute(
        onFinished: (result) {
          res = result;
        },
      );

      expect(res, isNotNull);
      expect(res!.exitCode, equals(1));
      expect(res!.isSuccess, isFalse);
    });

    test('execute runs without onFinished callback without error', () async {
      final processes = Processes(harness.tempDir.path);
      await expectLater(
        processes.process('echo "side effect"').execute(),
        completes,
      );
    });
  });
}
