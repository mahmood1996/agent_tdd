import 'dart:async';
import 'dart:convert';
import 'package:agent_harness/agent_harness.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleOutput Behavioral Tests', () {
    group('Text Mode (isJsonMode: false)', () {
      test('info prints message with info icon prefix', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: false, printHandler: outputs.add);

        output.info('System status nominal');

        expect(outputs, equals(['ℹ️  System status nominal']));
      });

      test('warning prints message with warning icon prefix', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: false, printHandler: outputs.add);

        output.warning('Deprecation notice');

        expect(outputs, equals(['⚠️  Deprecation notice']));
      });

      test('error prints message with error icon prefix', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: false, printHandler: outputs.add);

        output.error('Compilation failed');

        expect(outputs, equals(['❌ Compilation failed']));
      });

      test('reportSuccess formats success message with phase prefix', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: false, printHandler: outputs.add);
        const state = FakeHarnessState(
          phase: 'GREEN',
          editablePatterns: ['lib/**/*.dart'],
          readOnlyPatterns: ['test/**/*.dart'],
        );

        output.reportSuccess(message: 'All tests passed', state: state);

        expect(outputs, equals(['ℹ️  [GREEN] All tests passed']));
      });

      test('reportFailure formats error message with phase prefix', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: false, printHandler: outputs.add);
        const state = FakeHarnessState(
          phase: 'RED',
          editablePatterns: ['test/**/*.dart'],
          readOnlyPatterns: ['lib/**/*.dart'],
        );

        output.reportFailure(error: 'Assertion failed', state: state);

        expect(outputs, equals(['❌ [RED] Assertion failed']));
      });
    });

    group('JSON Mode (isJsonMode: true)', () {
      test('info, warning, and error emit no output', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: true, printHandler: outputs.add);

        output.info('Info message');
        output.warning('Warning message');
        output.error('Error message');

        expect(outputs, isEmpty);
      });

      test('reportSuccess outputs serialized JSON response', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: true, printHandler: outputs.add);
        const state = FakeHarnessState(
          phase: 'GREEN',
          editablePatterns: ['lib/**/*.dart'],
          readOnlyPatterns: ['test/**/*.dart'],
          nextCommand: 'agent-tdd complete',
        );

        output.reportSuccess(message: 'Phase transition allowed', state: state);

        expect(outputs.length, equals(1));
        final decoded = jsonDecode(outputs.first) as Map<String, dynamic>;
        expect(decoded['success'], isTrue);
        expect(decoded['message'], equals('Phase transition allowed'));
        expect(decoded['phase'], equals('GREEN'));
        expect(decoded['instructions_for_agent'],
            equals('Phase transition allowed'));
        expect(decoded['allowed_actions'], {
          'editable_files': ['lib/**/*.dart'],
          'read_only_files': ['test/**/*.dart'],
          'next_command': 'agent-tdd complete',
        });
      });

      test('reportFailure outputs serialized JSON error response', () {
        final outputs = <String>[];
        final output =
            ConsoleOutput(isJsonMode: true, printHandler: outputs.add);
        const state = FakeHarnessState(
          phase: 'RED',
          editablePatterns: ['test/**/*.dart'],
          readOnlyPatterns: ['lib/**/*.dart'],
        );

        output.reportFailure(error: 'Test suite failed', state: state);

        expect(outputs.length, equals(1));
        final decoded = jsonDecode(outputs.first) as Map<String, dynamic>;
        expect(decoded['success'], isFalse);
        expect(decoded['error'], equals('Test suite failed'));
        expect(decoded['phase'], equals('RED'));
        expect(decoded['instructions_for_agent'],
            equals('Fix error: Test suite failed'));
        expect(decoded['allowed_actions'], {
          'editable_files': ['test/**/*.dart'],
          'read_only_files': ['lib/**/*.dart'],
        });
      });
    });

    test('defaults to standard print when printHandler is omitted', () {
      final printedLines = <String>[];
      final output = ConsoleOutput(isJsonMode: false);

      runZoned(
        () {
          output.info('Default print message');
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            printedLines.add(line);
          },
        ),
      );

      expect(printedLines, equals(['ℹ️  Default print message']));
    });
  });
}

final class FakeHarnessState implements HarnessState {
  const FakeHarnessState({
    required this.phase,
    required this.editablePatterns,
    required this.readOnlyPatterns,
    this.nextCommand,
    this.extra = const {},
  });

  @override
  final String phase;

  @override
  final String? nextCommand;

  @override
  final Map<String, dynamic> extra;

  @override
  final List<String> editablePatterns;

  @override
  final List<String> readOnlyPatterns;
}
