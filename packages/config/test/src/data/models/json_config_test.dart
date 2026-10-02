import 'package:test/test.dart';
import 'package:config/config.dart';

void main() {
  group('JsonConfig', () {
    test('retrieves existing value by key', () {
      final ReadableConfig config = JsonConfig('{"name": "Agent", "port": 8080}');
      expect(config.valueBy<String>('name', 'Default'), equals('Agent'));
      expect(config.valueBy<int>('port', 80), equals(8080));
    });

    test('returns fallback value when key is missing or null', () {
      final ReadableConfig config = JsonConfig('{"name": "Agent"}');
      expect(config.valueBy<String>('host', 'localhost'), equals('localhost'));
    });
  });
}
