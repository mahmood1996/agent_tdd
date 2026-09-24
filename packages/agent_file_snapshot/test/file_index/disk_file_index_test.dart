import 'dart:io';

import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DiskFileIndex', () {
    late Directory tempDir;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('disk_file_index_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('snapshotOf includes matched files in filePaths', () async {
      await File(p.join(tempDir.path, 'sample.dart'))
          .writeAsString('void main() {}');

      final index = DiskFileIndex(baseDir: tempDir.path);
      final snapshot = await index.snapshotOf(['*.dart']);

      expect(snapshot.filePaths, contains('sample.dart'));
    });

    test('fingerprint returns a non-empty SHA-256 string for a matched file',
        () async {
      await File(p.join(tempDir.path, 'sample.dart'))
          .writeAsString('void main() {}');

      final index = DiskFileIndex(baseDir: tempDir.path);
      final snapshot = await index.snapshotOf(['*.dart']);

      expect(snapshot.fingerprint('sample.dart'), isNotEmpty);
    });

    test('snapshotOf returns empty snapshot when no files match', () async {
      final index = DiskFileIndex(baseDir: tempDir.path);
      final snapshot = await index.snapshotOf(['*.dart']);

      expect(snapshot.filePaths, isEmpty);
    });

    test('snapshotOf handles nested directory glob patterns', () async {
      final subDir = Directory(p.join(tempDir.path, 'lib', 'src'));
      await subDir.create(recursive: true);
      await File(p.join(subDir.path, 'nested.dart'))
          .writeAsString('class Foo {}');

      final index = DiskFileIndex(baseDir: tempDir.path);
      final snapshot = await index.snapshotOf(['lib/**/*.dart']);

      expect(snapshot.filePaths, contains('lib/src/nested.dart'));
    });

    test('does not include files that do not match the pattern', () async {
      await File(p.join(tempDir.path, 'sample.dart'))
          .writeAsString('void main() {}');
      await File(p.join(tempDir.path, 'readme.txt'))
          .writeAsString('readme');

      final index = DiskFileIndex(baseDir: tempDir.path);
      final snapshot = await index.snapshotOf(['*.dart']);

      expect(snapshot.filePaths, contains('sample.dart'));
      expect(snapshot.filePaths, isNot(contains('readme.txt')));
    });
  });
}
