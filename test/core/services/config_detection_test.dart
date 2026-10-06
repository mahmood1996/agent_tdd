import 'package:agent_tdd/src/core/services/config_detection.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('config_detection_test_');

  late ConfigDetection _detection;

  setUp(() {
    _detection = ConfigDetection();
  });

  group('ConfigDetection Solitary Unit Tests', () {
    test('detects Dart project', () async {
      harness.createFile('pubspec.yaml', 'name: my_dart_app\n');
      final config = await _detection.detectedConfig(harness.tempDir.path);

      expect(config.runner, equals('dart'));
      expect(config.testCommand, equals('dart test'));
    });

    test('detects Flutter project', () async {
      harness.createFile(
        'pubspec.yaml',
        'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
      );
      final config = await _detection.detectedConfig(harness.tempDir.path);

      expect(config.runner, equals('flutter'));
      expect(config.testCommand, equals('flutter test'));
    });

    test('returns default dart config when no detection matches', () async {
      final config = await _detection.detectedConfig(harness.tempDir.path);

      expect(config.runner, equals('dart'));
    });
  });
}
