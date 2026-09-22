import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('FileSnapshotDiff Tests', () {
    test('FileSnapshotDiff correctly evaluates added, deleted, and modified files', () {
      final originalHashes = {
        'kept.txt': 'hash1',
        'modified.txt': 'hash2_old',
        'deleted.txt': 'hash3',
      };
      final currentHashes = {
        'kept.txt': 'hash1',
        'modified.txt': 'hash2_new',
        'added.txt': 'hash4',
      };

      final diff = FileSnapshotDiff(
        originalHashes: originalHashes,
        currentHashes: currentHashes,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.modifiedFiles, equals(['modified.txt']));
      expect(diff.deletedFiles, equals(['deleted.txt']));
      expect(diff.addedFiles, equals(['added.txt']));
    });

    test('FileSnapshotDiff returns false for hasChanges when snapshots are identical', () {
      final hashes = {'file1.txt': 'hash1'};
      final diff = FileSnapshotDiff(
        originalHashes: hashes,
        currentHashes: Map.from(hashes),
      );

      expect(diff.hasChanges, isFalse);
      expect(diff.modifiedFiles, isEmpty);
      expect(diff.deletedFiles, isEmpty);
      expect(diff.addedFiles, isEmpty);
    });
  });
}
