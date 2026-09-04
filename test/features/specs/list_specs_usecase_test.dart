import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('list_specs_usecase_test_');

  group('ListSpecsUseCase Behavioral Solitary Unit Tests', () {
    test('execute returns empty list and zero summary when no specs exist', () async {
      final useCase = ListSpecsUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute();

      expect(res.specs, isEmpty);
      expect(res.summary['total'], equals(0));
      expect(res.summary['completed'], equals(0));
    });

    test('execute lists all specs and returns correct summary breakdown', () async {
      final addUseCase = AddSpecUseCase(projectDir: harness.tempDir.path);
      await addUseCase.execute('Feature A');
      await addUseCase.execute('Feature B');

      final listUseCase = ListSpecsUseCase(projectDir: harness.tempDir.path);
      final res = await listUseCase.execute();

      expect(res.specs.length, equals(2));
      expect(res.summary['total'], equals(2));
      expect(res.summary['completed'], equals(0));
      expect(res.specs[0].title, equals('Feature A'));
      expect(res.specs[1].title, equals('Feature B'));
    });
  });
}
