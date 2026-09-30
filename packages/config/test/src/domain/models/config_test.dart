import 'package:test/test.dart';
import 'package:config/config.dart';

class TestConfig implements Config {
  @override
  V valueBy<V>(String key, V fallback) => fallback;

  @override
  Map<String, dynamic> toMap() => {'test': true};
}

class TestConfigStore implements ConfigStore {
  Config? _current;

  @override
  Future<Config?> config() async => _current;

  @override
  Future<void> save(SerializableConfig conf) async {
    _current = TestConfig();
  }
}

void main() {
  group('Domain interfaces contract test', () {
    test('Config conforms to ReadableConfig and SerializableConfig', () {
      final Config config = TestConfig();
      expect(config, isA<ReadableConfig>());
      expect(config, isA<SerializableConfig>());
      expect(config.valueBy<String>('missing', 'default'), equals('default'));
      expect(config.toMap(), equals({'test': true}));
    });

    test('ConfigStore interface contract', () async {
      final ConfigStore store = TestConfigStore();
      expect(await store.config(), isNull);
      await store.save(TestConfig());
      expect(await store.config(), isNotNull);
    });
  });
}
