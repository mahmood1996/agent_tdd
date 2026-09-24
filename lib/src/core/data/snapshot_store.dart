import 'dart:convert';
import 'dart:io';
import 'package:agent_file_snapshot/agent_file_snapshot.dart';
import 'package:path/path.dart' as p;

final class SnapshotStore {
  SnapshotStore({required String projectDir}) : _projectDir = projectDir;

  final String _projectDir;

  static const String snapshotFileName = '.agent_tdd_snapshot.json';

  Future<FileSnapshot> capture(String globPattern) async {
    return DiskFileIndex(baseDir: _projectDir).snapshotOf([globPattern]);
  }

  Future<void> save(FileSnapshot snapshot) async {
    final file = File(p.join(_projectDir, snapshotFileName));
    await file.writeAsString(jsonEncode(snapshot.fingerprints));
  }

  Future<List<String>> verifyIntegrity(String globPattern) async {
    final original = await _savedSnapshot();
    if (original == null) return [];

    final originalHashes = original.fingerprints;
    if (originalHashes.isEmpty) return [];

    final current = await capture(globPattern);
    final currentHashes = current.fingerprints;

    return FileSnapshotDiff(
      originalHashes: originalHashes,
      currentHashes: currentHashes,
    ).violations;
  }

  Future<FileSnapshot?> _savedSnapshot() async {
    final file = File(p.join(_projectDir, snapshotFileName));

    return await file.exists()
        ? FileSnapshot(
            Map<String, String>.from(jsonDecode(await file.readAsString())),
          )
        : null;
  }

  Future<void> delete() async {
    final file = File(p.join(_projectDir, snapshotFileName));
    if (!await file.exists()) return;
    await file.delete();
  }
}

extension ViolationsOfDiff on FileSnapshotDiff {
  List<String> get violations {
    return [
      ...modifiedFiles.map((e) => '$e (MODIFIED)'),
      ...deletedFiles.map((e) => '$e (DELETED)'),
      ...addedFiles.map((e) => '$e (ADDED)'),
    ];
  }
}
