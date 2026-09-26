import '../../domain/models/file_snapshot/file_snapshot.dart';

/// Abstract interface for persisting and retrieving a [FileSnapshot].
///
/// A [SnapshotStore] is the storage boundary — it knows how to durably
/// save a snapshot and restore it on a subsequent run. All I/O happens
/// here; [FileSnapshot] itself remains a pure value object.
///
/// Example:
/// ```dart
/// final store = FileSnapshotStore(path: '.snapshot.json');
/// await store.save(snapshot);
/// final restored = await store.savedSnapshot();
/// ```
abstract interface class SnapshotStore {
  /// Returns the previously saved [FileSnapshot], or an empty snapshot if
  /// no snapshot has been persisted yet.
  Future<FileSnapshot> savedSnapshot();

  /// Persists [snapshot] so it can be retrieved by [savedSnapshot] later.
  Future<void> save(FileSnapshot snapshot);

  /// Deletes the persisted snapshot, if one exists.
  ///
  /// No-op when no snapshot has been saved yet.
  Future<void> delete();
}
