import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('spec_store_test_');

  late SpecStore _store;

  setUp(() {
    _store = SpecStore(projectDir: harness.tempDir.path);
  });

  group('SpecStore Solitary Unit Tests', () {
    test('Add, save and retrieve specs', () async {
      await _store.addSpec('Test spec 1', description: 'Desc 1');
      var list = await _store.specs();
      expect(list.length, equals(1));
      expect(list[0].id, equals(1));
      expect(list[0].status, equals('pending'));

      await _store.addSpec('Test spec 2');
      list = await _store.specs();
      expect(list.length, equals(2));
      expect(list[1].id, equals(2));

      final active = await _store.nextPendingSpec();
      expect(active?.title, equals('Test spec 1'));
    });

    test('Status updates correctly', () async {
      await _store.addSpec('Spec 1');
      await _store.updateSpecStatus(1, 'red');

      final active = await _store.activeSpec();
      expect(active?.id, equals(1));
      expect(active?.status, equals('red'));
    });

    test('Import specs from markdown', () async {
      final mdFile = harness.createFile('specs.md', '''
# Backlog
- [ ] Feature A
- [x] Feature B
''');

      await _store.importSpecsFrom(mdFile.path);

      final list = await _store.specs();
      expect(list.length, equals(2));
      expect(list[0].title, equals('Feature A'));
      expect(list[0].status, equals('pending'));
      expect(list[1].title, equals('Feature B'));
      expect(list[1].status, equals('done'));
    });
  });
}
