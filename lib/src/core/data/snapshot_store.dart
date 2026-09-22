import 'dart:convert';
import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

final class SnapshotStore {
  SnapshotStore({required String projectDir}) : _projectDir = projectDir;

  final String _projectDir;

  static const String snapshotFileName = '.agent_tdd_snapshot.json';

  Future<FileSnapshot> capture(String globPattern) async {
    return PatternFileSnapshot(
      patterns: [globPattern],
      baseDir: _projectDir,
    );
  }

  Future<void> save(FileSnapshot snapshot) async {
    final file = File(p.join(_projectDir, snapshotFileName));
    final hashes = await snapshot.hashes();
    await file.writeAsString(jsonEncode(hashes));
  }

  Future<List<String>> verifyIntegrity(String globPattern) async {
    final original = await _savedSnapshot();
    if (original == null) return [];

    final originalHashes = await original.hashes();
    if (originalHashes.isEmpty) return [];

    final current = await capture(globPattern);
    final currentHashes = await current.hashes();

    return FileSnapshotDiff(
      originalHashes: originalHashes,
      currentHashes: currentHashes,
    ).violations;
  }

  Future<FileSnapshot?> _savedSnapshot() async {
    final file = File(p.join(_projectDir, snapshotFileName));
    if (!await file.exists()) return null;
    return JsonFileSnapshot(file);
  }

  Future<void> delete() async {
    final file = File(p.join(_projectDir, snapshotFileName));
    if (!await file.exists()) return;
    await file.delete();
  }
}

extension ViolationsOfDiff on FileSnapshotDiff {
  List<String> get violations => [
        ...modifiedFiles.map((e) => '$e (MODIFIED)'),
        ...deletedFiles.map((e) => '$e (DELETED)'),
        ...addedFiles.map((e) => '$e (ADDED)'),
      ];
}
