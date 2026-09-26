import 'dart:convert';
import 'package:agent_harness/agent_harness.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleOutput', () {
    late List<String> outputs;
    late ConsoleOutput console;

    setUp(() {
      outputs = [];
      console = ConsoleOutput(printHandler: outputs.add);
    });

    test('display forwards the raw string to the printHandler', () {
      console.display('hello world');

      expect(outputs, equals(['hello world']));
    });

    test('display can be called multiple times independently', () {
      console.display('first');
      console.display('second');

      expect(outputs, equals(['first', 'second']));
    });
  });

  group('Message factories', () {
    test('Message.info produces info-prefixed string', () {
      expect(Message.info('System nominal').toString(),
          equals('ℹ️ System nominal'));
    });

    test('Message.warning produces ANSI yellow warning string', () {
      expect(
        Message.warning('Deprecation notice').toString(),
        equals('\x1B[33m⚠️  Deprecation notice\x1B[0m'),
      );
    });

    test('Message.error produces ANSI red error string', () {
      expect(
        Message.error('Compilation failed').toString(),
        equals('\x1B[31m❌ Compilation failed\x1B[0m'),
      );
    });

    test('Message.success produces ANSI green success string', () {
      expect(
        Message.success('All tests passed').toString(),
        equals('\x1B[32m✅ All tests passed\x1B[0m'),
      );
    });

    test('Message.json serializes a Map to JSON string', () {
      final msg = Message.json({'status': 'ok', 'count': 3});
      final decoded = jsonDecode(msg.toString()) as Map<String, dynamic>;

      expect(decoded['status'], equals('ok'));
      expect(decoded['count'], equals(3));
    });

    test('Message.json round-trips nested structures', () {
      final payload = {
        'phase': 'GREEN',
        'allowed_actions': {
          'editable_files': ['lib/**/*.dart'],
        },
      };
      final msg = Message.json(payload);
      final decoded = Map<String, dynamic>.from(jsonDecode(msg.toString()));

      expect(decoded['phase'], equals('GREEN'));
      expect(
        decoded['allowed_actions']['editable_files'],
        equals(['lib/**/*.dart']),
      );
    });
  });

  group('ConsoleOutput + Message integration', () {
    late List<String> outputs;
    late ConsoleOutput console;

    setUp(() {
      outputs = [];
      console = ConsoleOutput(printHandler: outputs.add);
    });

    test('displays info message via Message.info', () {
      console.display(Message.info('Starting phase').toString());

      expect(outputs, equals(['ℹ️ Starting phase']));
    });

    test('displays error message with ANSI codes via Message.error', () {
      console.display(Message.error('Test failed').toString());

      expect(outputs, equals(['\x1B[31m❌ Test failed\x1B[0m']));
    });

    test('displays success message with ANSI codes via Message.success', () {
      console.display(Message.success('Phase complete').toString());

      expect(outputs, equals(['\x1B[32m✅ Phase complete\x1B[0m']));
    });

    test('displays structured JSON payload via Message.json', () {
      console.display(
          Message.json({'success': true, 'phase': 'GREEN'}).toString());

      expect(outputs.length, equals(1));
      final decoded = Map<String, dynamic>.from(jsonDecode(outputs.first));
      expect(decoded['success'], isTrue);
      expect(decoded['phase'], equals('GREEN'));
    });
  });
}
