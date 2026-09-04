import 'dart:convert';
import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

final class SnapshotStore {
  SnapshotStore({required String projectDir})
      : _projectDir = projectDir,
        _engine = FileSnapshotEngine();

  final String _projectDir;
  final FileSnapshotEngine _engine;

  static const String snapshotFileName = '.agent_tdd_snapshot.json';

  Future<FileSnapshot> capture(String globPattern) async {
    return await _engine.computeHashes([globPattern], baseDir: _projectDir);
  }

  Future<void> save(FileSnapshot snapshot) async {
    final file = File(p.join(_projectDir, snapshotFileName));
    await file.writeAsString(jsonEncode(snapshot.toJson()));
  }

  Future<List<String>> verifyIntegrity(String globPattern) async {
    final original = await _savedSnapshot();
    if (original == null) return [];

    final current = await capture(globPattern);
    final diff = original.compareTo(current);

    final violations = <String>[];
    for (final file in diff.modifiedFiles) {
      violations.add('$file (MODIFIED)');
    }
    for (final file in diff.deletedFiles) {
      violations.add('$file (DELETED)');
    }
    for (final file in diff.addedFiles) {
      violations.add('$file (ADDED)');
    }

    return violations;
  }

  Future<FileSnapshot?> _savedSnapshot() async {
    final file = File(p.join(_projectDir, snapshotFileName));
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return FileSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete() async {
    final file = File(p.join(_projectDir, snapshotFileName));
    if (!await file.exists()) return;
    await file.delete();
  }
}
