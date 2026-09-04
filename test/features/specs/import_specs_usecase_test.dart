import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('import_specs_usecase_test_');

  group('ImportSpecsUseCase Behavioral Solitary Unit Tests', () {
    test('execute imports specs from markdown backlog file', () async {
      final mdFile = harness.createFile('backlog.md', '''
# Roadmap
- [ ] Task 1: Setup database
- [x] Task 2: Initial commit
''');

      final importUseCase = ImportSpecsUseCase(projectDir: harness.tempDir.path);
      final res = await importUseCase.execute(mdFile.path);

      expect(res.filePath, equals(mdFile.path));

      final specStore = SpecStore(projectDir: harness.tempDir.path);
      final importedSpecs = await specStore.specs();
      expect(importedSpecs.length, equals(2));
      expect(importedSpecs[0].title, equals('Task 1: Setup database'));
      expect(importedSpecs[0].status, equals('pending'));
      expect(importedSpecs[1].title, equals('Task 2: Initial commit'));
      expect(importedSpecs[1].status, equals('done'));
    });
  });
}
