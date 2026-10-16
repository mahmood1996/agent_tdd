import 'dart:io';

import 'package:processes/processes.dart';
import 'package:test/test.dart';

class _CustomResult implements ExecutableProcessResult {
  @override
  final int exitCode;
  @override
  final String stdout;
  @override
  final String stderr;

  const _CustomResult(this.exitCode, this.stdout, this.stderr);
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('process_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Processes & ExecutableProcess Solitary Unit Tests', () {
    test('execute runs successful command and invokes onFinished callback',
        () async {
      final processes = Processes(tempDir.path);
      ExecutableProcessResult? res;

      await processes.process(
        'echo "hello world"',
        onFinished: (result) {
          res = result;
        },
      ).execute();

      expect(res, isNotNull);
      expect(res!.exitCode, equals(0));
      expect(res!.isSuccess, isTrue);
      expect(res!.stdout.trim(), equals('hello world'));
    });

    test('execute captures non-zero exit code on failure', () async {
      final processes = Processes(tempDir.path);
      ExecutableProcessResult? res;

      await processes.process(
        'exit 1',
        onFinished: (result) {
          res = result;
        },
      ).execute();

      expect(res, isNotNull);
      expect(res!.exitCode, equals(1));
      expect(res!.isSuccess, isFalse);
    });

    test('execute runs without onFinished callback without error', () async {
      final processes = Processes(tempDir.path);
      await expectLater(
        processes.process('echo "side effect"').execute(),
        completes,
      );
    });
  });

  group('ExecutableProcessResult Interface & Extension Tests', () {
    test('wraps ProcessResult and converts output to string', () {
      final procResult = ProcessResult(1234, 0, 'out', 'err');
      final result = ExecutableProcessResult(procResult);

      expect(result.exitCode, equals(0));
      expect(result.stdout, equals('out'));
      expect(result.stderr, equals('err'));
      expect(result.isSuccess, isTrue);
      expect(result.combinedOutput, equals('out\nerr'));
    });

    test('converts non-string stdout and stderr safely', () {
      final procResult = ProcessResult(1234, 42, [1, 2, 3], null);
      final result = ExecutableProcessResult(procResult);

      expect(result.exitCode, equals(42));
      expect(result.stdout, equals('[1, 2, 3]'));
      expect(result.stderr, equals('null'));
      expect(result.isSuccess, isFalse);
      expect(result.combinedOutput, equals('[1, 2, 3]\nnull'));
    });

    test('custom implementation conforms to interface and uses extension', () {
      final custom = _CustomResult(0, 'hello', '');
      expect(custom.exitCode, equals(0));
      expect(custom.stdout, equals('hello'));
      expect(custom.stderr, isEmpty);
      expect(custom.isSuccess, isTrue);
      expect(custom.combinedOutput, equals('hello'));
    });
  });
}
