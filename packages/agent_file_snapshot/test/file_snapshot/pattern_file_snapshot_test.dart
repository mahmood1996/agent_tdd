import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('PatternFileSnapshot Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('pattern_snapshot_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('computes hashes and verifies isUnchanged files', () async {
      final file1 = File(p.join(tempDir.path, 'sample.txt'));
      await file1.writeAsString('Hello World');

      final snapshot = PatternFileSnapshot(
        patterns: ['*.txt'],
        baseDir: tempDir.path,
      );

      final hashes = await snapshot.hashes();
      expect(hashes.containsKey('sample.txt'), isTrue);

      final isUnchanged = await snapshot.isUnchanged(
        baseDir: tempDir.path,
      );
      expect(isUnchanged, isTrue);
    });

    test('detects file modifications in diffFromDisk', () async {
      final file1 = File(p.join(tempDir.path, 'sample.txt'));
      await file1.writeAsString('Initial Content');

      final patternSnapshot = PatternFileSnapshot(
        patterns: ['*.txt'],
        baseDir: tempDir.path,
      );
      final initialHashes = await patternSnapshot.hashes();
      final beforeSnapshot = MemoryFileSnapshot(initialHashes);

      // Modify file
      await file1.writeAsString('Modified Content');

      final diff = await beforeSnapshot.diffFromDisk(
        baseDir: tempDir.path,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.modifiedFiles, contains('sample.txt'));
    });
  });
}
