import 'package:test/test.dart';
import 'package:config/src/data/models/json_config.dart';

void main() {
  group('JsonConfig', () {
    test('retrieves existing value by key', () {
      final config = JsonConfig('{"name": "Agent", "port": 8080}');
      expect(config.valueBy<String>('name', 'Default'), equals('Agent'));
      expect(config.valueBy<int>('port', 80), equals(8080));
    });

    test('returns fallback value when key is missing', () {
      final config = JsonConfig('{"name": "Agent"}');
      expect(config.valueBy<String>('host', 'localhost'), equals('localhost'));
    });

    test('serializes to map', () {
      final jsonStr = '{"key": "value"}';
      final config = JsonConfig(jsonStr);
      expect(config.toMap(), equals({'key': 'value'}));
    });
  });
}
