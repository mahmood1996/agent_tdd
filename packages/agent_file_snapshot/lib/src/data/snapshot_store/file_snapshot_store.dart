import 'dart:convert';
import 'dart:io';

import '../../domain/models/file_snapshot/file_snapshot.dart';
import 'snapshot_store.dart';

/// Concrete [SnapshotStore] that persists a [FileSnapshot] as a JSON file
/// on the local file system.
///
/// The snapshot is serialised as a flat JSON object mapping relative file
/// paths to their SHA-256 fingerprints, e.g.:
/// ```json
/// {
///   "lib/src/foo.dart": "abc123...",
///   "test/foo_test.dart": "def456..."
/// }
/// ```
final class FileSnapshotStore implements SnapshotStore {
  const FileSnapshotStore({required String path}) : _path = path;

  final String _path;

  @override
  Future<FileSnapshot> savedSnapshot() async {
    final file = File(_path);
    if (!await file.exists()) return FileSnapshot(const {});

    final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return FileSnapshot(raw.cast<String, String>());
  }

  @override
  Future<void> save(FileSnapshot snapshot) async {
    final file = File(_path);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(FingerPrints(snapshot)));
  }

  @override
  Future<void> delete() async {
    final file = File(_path);
    if (await file.exists()) await file.delete();
  }
}
