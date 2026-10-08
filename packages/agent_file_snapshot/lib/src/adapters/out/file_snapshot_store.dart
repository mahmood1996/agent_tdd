import 'dart:io';

import 'package:resource/resource.dart';

import '../../application/domain/models/file_snapshot.dart';
import '../../application/ports/out/snapshot_store.dart';

/// Concrete [SnapshotStore] that persists a [FileSnapshot] using a [Resource].
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
  FileSnapshotStore({required String path})
      : _resource = JsonResource(File(path));

  final Resource<dynamic> _resource;

  @override
  Future<FileSnapshot> savedSnapshot() async {
    try {
      return await _storedFileSnapshot();
    } on ResourceNotFoundException {
      return FileSnapshot(const {});
    }
  }

  Future<FileSnapshot> _storedFileSnapshot() async {
    return FileSnapshot(
      switch (await _resource.content()) {
        Map content => content.cast<String, String>(),
        null || _ => const {},
      },
    );
  }

  @override
  Future<void> save(FileSnapshot snapshot) async {
    await _resource.save(FingerPrints(snapshot));
  }

  @override
  Future<void> delete() async {
    await _resource.delete();
  }
}
