import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('FileSnapshot', () {
    group('factory', () {
      test('exposes correct filePaths', () {
        final snapshot = FileSnapshot({
          'file1.dart': 'hash1',
          'file2.dart': 'hash2',
        });
        expect(snapshot.filePaths, containsAll(['file1.dart', 'file2.dart']));
      });

      test('fingerprint returns correct hash for a known path', () {
        final snapshot = FileSnapshot({'file1.dart': 'hash1'});
        expect(snapshot.fingerprint('file1.dart'), equals('hash1'));
      });

      test('fingerprint returns empty string for unknown path', () {
        final snapshot = FileSnapshot({'file1.dart': 'hash1'});
        expect(snapshot.fingerprint('unknown.dart'), equals(''));
      });
    });

    group('fingerprints extension getter', () {
      test('returns full path → fingerprint map', () {
        final map = {'file1.dart': 'hash1', 'file2.dart': 'hash2'};
        final snapshot = FileSnapshot(map);
        expect(snapshot.fingerprints, equals(map));
      });

      test('returns empty map for empty snapshot', () {
        expect(FileSnapshot(const {}).fingerprints, isEmpty);
      });
    });

    group('diff extension', () {
      test('detects modified, added, and deleted files', () {
        final original = FileSnapshot({
          'kept.dart': 'hash1',
          'modified.dart': 'hash_old',
          'deleted.dart': 'hash3',
        });
        final current = FileSnapshot({
          'kept.dart': 'hash1',
          'modified.dart': 'hash_new',
          'added.dart': 'hash4',
        });

        final diff = original.diff(current);

        expect(diff.hasChanges, isTrue);
        expect(diff.modifiedFiles, contains('modified.dart'));
        expect(diff.deletedFiles, contains('deleted.dart'));
        expect(diff.addedFiles, contains('added.dart'));
        expect(diff.modifiedFiles, isNot(contains('kept.dart')));
      });

      test('returns no changes for identical snapshots', () {
        final snapshot = FileSnapshot({'file1.dart': 'hash1'});
        final diff = snapshot.diff(FileSnapshot({'file1.dart': 'hash1'}));

        expect(diff.hasChanges, isFalse);
        expect(diff.modifiedFiles, isEmpty);
        expect(diff.deletedFiles, isEmpty);
        expect(diff.addedFiles, isEmpty);
      });
    });
  });
}
