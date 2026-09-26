import 'dart:io';

import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FileSnapshotStore', () {
    late Directory tempDir;
    late String storePath;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('file_snapshot_store_test_');
      storePath = p.join(tempDir.path, '.snapshot.json');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('savedSnapshot returns empty snapshot when no file exists', () async {
      final store = FileSnapshotStore(path: storePath);
      final snapshot = await store.savedSnapshot();

      expect(snapshot.filePaths, isEmpty);
    });

    test('save and savedSnapshot round-trip fingerprints correctly', () async {
      final original = FileSnapshot({
        'lib/src/foo.dart': 'abc123',
        'test/foo_test.dart': 'def456',
      });

      final store = FileSnapshotStore(path: storePath);
      await store.save(original);
      final restored = await store.savedSnapshot();

      expect(restored.filePaths,
          containsAll(['lib/src/foo.dart', 'test/foo_test.dart']));
      expect(restored.fingerprint('lib/src/foo.dart'), equals('abc123'));
      expect(restored.fingerprint('test/foo_test.dart'), equals('def456'));
    });

    test('save overwrites a previously saved snapshot', () async {
      final store = FileSnapshotStore(path: storePath);

      await store.save(FileSnapshot({'old.dart': 'hash_old'}));
      await store.save(FileSnapshot({'new.dart': 'hash_new'}));

      final restored = await store.savedSnapshot();

      expect(restored.filePaths, isNot(contains('old.dart')));
      expect(restored.filePaths, contains('new.dart'));
      expect(restored.fingerprint('new.dart'), equals('hash_new'));
    });

    test('save creates intermediate directories if needed', () async {
      final nestedPath =
          p.join(tempDir.path, 'deep', 'nested', '.snapshot.json');
      final store = FileSnapshotStore(path: nestedPath);

      await expectLater(
        store.save(FileSnapshot({'file.dart': 'hash1'})),
        completes,
      );
      expect(File(nestedPath).existsSync(), isTrue);
    });

    test('savedSnapshot returns empty snapshot for an empty save', () async {
      final store = FileSnapshotStore(path: storePath);
      await store.save(FileSnapshot(const {}));
      final restored = await store.savedSnapshot();

      expect(restored.filePaths, isEmpty);
    });
  });
}
