import 'package:test/test.dart';
import 'package:config/config.dart';

void main() {
  group('JsonConfig', () {
    test('retrieves existing value by key', () {
      final Config config = JsonConfig('{"name": "Agent", "port": 8080}');
      expect(config.valueBy<String>('name', 'Default'), equals('Agent'));
      expect(config.valueBy<int>('port', 80), equals(8080));
    });

    test('returns fallback value when key is missing or null', () {
      final Config config = JsonConfig('{"name": "Agent"}');
      expect(config.valueBy<String>('host', 'localhost'), equals('localhost'));
    });

    test('serializes underlying map', () {
      final config = JsonConfig('{"key": "value"}');
      expect(config.toMap(), equals({'key': 'value'}));
    });

    test('lazily evaluates json map', () {
      int evaluationCount = 0;
      final config = JsonConfig.fromSupplier(() {
        evaluationCount++;
        return {'lazyKey': 'lazyValue'};
      });

      expect(evaluationCount, equals(0));
      expect(config.valueBy<String>('lazyKey', 'fallback'), equals('lazyValue'));
      expect(evaluationCount, greaterThanOrEqualTo(1));
    });
  });
}
