import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('config_store_test_');

  late ConfigStore _store;

  setUp(() {
    _store = ConfigStore(projectDir: harness.tempDir.path);
  });

  group('ConfigStore Solitary Unit Tests', () {
    test('config loads configuration from file when .tddrc.yaml exists',
        () async {
      const customConfig = TddConfig.pytest();
      await _store.save(customConfig);

      final config = await _store.config();
      expect(config.runner, equals('pytest'));
      expect(config.testCommand, equals('pytest'));
    });

    test('save and load config works', () async {
      const config = TddConfig.vitest();
      await _store.save(config);

      final loaded = await _store.config();
      expect(loaded.runner, equals('vitest'));
      expect(loaded.testCommand, equals('npx vitest run'));
      expect(loaded.analyzeCommand, equals('npx eslint . --max-warnings 0'));
    });
  });
}
