import 'dart:convert';
import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('JsonFileSnapshot Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('json_snapshot_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('JsonFileSnapshot loads hashes lazily from disk', () async {
      final jsonFile = File(p.join(tempDir.path, 'snapshot.json'));
      await jsonFile.writeAsString(jsonEncode({
        'file1.dart': 'hash1',
        'file2.dart': 'hash2',
      }));

      final snapshot = JsonFileSnapshot(jsonFile);
      final hashes = await snapshot.hashes();

      expect(hashes, equals({'file1.dart': 'hash1', 'file2.dart': 'hash2'}));
    });

    test('JsonFileSnapshot parses nested file_hashes object format', () async {
      final jsonFile = File(p.join(tempDir.path, 'snapshot.json'));
      await jsonFile.writeAsString(jsonEncode({
        'file_hashes': {
          'main.dart': 'abc123hash',
        }
      }));

      final snapshot = JsonFileSnapshot(jsonFile);
      final hashes = await snapshot.hashes();

      expect(hashes, equals({'main.dart': 'abc123hash'}));
    });
  });
}
