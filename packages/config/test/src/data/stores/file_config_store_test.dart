import 'dart:io';
import 'package:test/test.dart';
import 'package:config/config.dart';

void main() {
  late Directory tempDir;
  late String filePath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('config_test_');
    filePath = '${tempDir.path}/app_config.yaml';
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileConfigStore', () {
    test('returns null when file does not exist', () async {
      final store = FileConfigStore(filePath);
      final conf = await store.config();
      expect(conf, isNull);
    });

    test('saving config', () async {
      final store = FileConfigStore(filePath);
      final initialConfig = JsonConfig(
        '{"environment": "production", "port": 443}',
      );

      await store.save(initialConfig);

      final loadedConfig = await store.config();
      expect(loadedConfig, isNotNull);
      expect(
        loadedConfig!.valueBy<String>('environment', 'dev'),
        equals('production'),
      );
      expect(loadedConfig.valueBy<int>('port', 80), equals(443));
    });

    test('returns null when file is empty', () async {
      await File(filePath).writeAsString('');
      final store = FileConfigStore(filePath);
      expect(await store.config(), isNull);
    });
  });
}
