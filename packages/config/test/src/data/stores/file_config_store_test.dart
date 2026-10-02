import 'dart:io';
import 'package:test/test.dart';
import 'package:config/config.dart';

final class _SerializableConfig implements SerializableConfig {
  _SerializableConfig() : this._(map: {});

  _SerializableConfig._({required this._map});

  final Map<String, dynamic> _map;

  _SerializableConfig withVariable(String key, dynamic value) =>
      _SerializableConfig._(map: {..._map, key: value});

  @override
  Map<String, dynamic> toMap() => Map.unmodifiable(_map);
}

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
    test('returns empty config when no config stored', () async {
      final store = FileConfigStore(filePath);

      final config = await store.config();

      expect(config.valueBy<int>('test', 12), equals(12));
    });

    test('saving config', () async {
      final store = FileConfigStore(filePath);

      final initialConfig = _SerializableConfig()
          .withVariable('environment', 'production')
          .withVariable('port', 443);

      await store.save(initialConfig);

      final loadedConfig = await store.config();

      expect(
        loadedConfig.valueBy<String>('environment', 'dev'),
        equals('production'),
      );

      expect(loadedConfig.valueBy<int>('port', 80), equals(443));
    });
  });
}
