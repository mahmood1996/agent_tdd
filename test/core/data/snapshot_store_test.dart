import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('snapshot_store_test_');

  group('SnapshotStore Integrity Solitary Unit Tests', () {
    test('Capture snapshot and verify unmodified files', () async {
      final testFile = harness.createFile('test/sample_test.dart', 'void main() {}');

      final store = SnapshotStore(projectDir: harness.tempDir.path);
      final snapshot = await store.capture('test/**/*.dart');
      await store.save(snapshot);

      final violations = await store.verifyIntegrity('test/**/*.dart');
      expect(violations, isEmpty);

      // Modify the test file
      testFile.writeAsStringSync('void main() { print("modified"); }');
      final violationsAfterEdit = await store.verifyIntegrity('test/**/*.dart');
      expect(violationsAfterEdit.length, equals(1));
      expect(
        violationsAfterEdit.first,
        contains('sample_test.dart (MODIFIED)'),
      );
    });
  });
}
