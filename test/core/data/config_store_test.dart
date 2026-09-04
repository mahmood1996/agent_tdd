import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('config_store_test_');

  group('ConfigStore Solitary Unit Tests', () {
    test('config detects Dart project', () async {
      harness.createFile('pubspec.yaml', 'name: my_dart_app\n');
      final store = ConfigStore(projectDir: harness.tempDir.path);
      final config = await store.config();

      expect(config.runner, equals('dart'));
      expect(config.testCommand, equals('dart test'));
    });

    test('config detects Flutter project', () async {
      harness.createFile(
        'pubspec.yaml',
        'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
      );
      final store = ConfigStore(projectDir: harness.tempDir.path);
      final config = await store.config();

      expect(config.runner, equals('flutter'));
      expect(config.testCommand, equals('flutter test'));
    });

    test('config returns auto-detected config when .tddrc.yaml is absent', () async {
      harness.createFile('pubspec.yaml', 'name: my_dart_app\n');
      final store = ConfigStore(projectDir: harness.tempDir.path);
      final config = await store.config();

      expect(config.runner, equals('dart'));
      expect(config.testCommand, equals('dart test'));
    });

    test('config loads configuration from file when .tddrc.yaml exists', () async {
      final store = ConfigStore(projectDir: harness.tempDir.path);
      final customConfig = TddConfig.presets['pytest']!;
      await store.save(customConfig);

      final config = await store.config();
      expect(config.runner, equals('pytest'));
      expect(config.testCommand, equals('pytest'));
    });

    test('save and load config works', () async {
      final store = ConfigStore(projectDir: harness.tempDir.path);
      final config = TddConfig.presets['vitest']!;
      await store.save(config);

      final loaded = await store.config();
      expect(loaded.runner, equals('vitest'));
      expect(loaded.testCommand, equals('npx vitest run'));
      expect(loaded.analyzeCommand, equals('npx eslint . --max-warnings 0'));
    });
  });
}
