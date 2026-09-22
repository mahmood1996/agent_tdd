import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryFileSnapshot Tests', () {
    test('returns in-memory hashes and computes diff against another snapshot', () async {
      final s1 = MemoryFileSnapshot({'file1.txt': 'hash1'});
      final s2 = MemoryFileSnapshot({'file1.txt': 'hash2', 'file2.txt': 'hash3'});

      final hashes = await s1.hashes();
      expect(hashes, equals({'file1.txt': 'hash1'}));

      final diff = await s1.diff(s2);
      expect(diff.hasChanges, isTrue);
      expect(diff.modifiedFiles, contains('file1.txt'));
      expect(diff.addedFiles, contains('file2.txt'));
    });
  });
}
