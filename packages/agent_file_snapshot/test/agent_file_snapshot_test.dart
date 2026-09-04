import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('agent_file_snapshot Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('snapshot_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('computes hashes and verifies unchanged files', () async {
      final engine = FileSnapshotEngine();

      final file1 = File(p.join(tempDir.path, 'sample.txt'));
      await file1.writeAsString('Hello World');

      final snapshot = await engine.computeHashes(
        ['*.txt'],
        baseDir: tempDir.path,
      );

      expect(snapshot.fileHashes.containsKey('sample.txt'), isTrue);

      final isUnchanged = await engine.verifyUnchanged(
        snapshot,
        baseDir: tempDir.path,
      );
      expect(isUnchanged, isTrue);
    });

    test('detects file modifications in diff', () async {
      final engine = FileSnapshotEngine();

      final file1 = File(p.join(tempDir.path, 'sample.txt'));
      await file1.writeAsString('Initial Content');

      final beforeSnapshot = await engine.computeHashes(
        ['*.txt'],
        baseDir: tempDir.path,
      );

      // Modify file
      await file1.writeAsString('Modified Content');

      final diff = await engine.checkDiff(
        beforeSnapshot,
        baseDir: tempDir.path,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.modifiedFiles, contains('sample.txt'));
    });
  });
}
