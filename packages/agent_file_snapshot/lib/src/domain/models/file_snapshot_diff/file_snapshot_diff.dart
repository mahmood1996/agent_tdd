import 'package:meta/meta.dart';

/// Abstract interface representing differences between two file snapshots
abstract interface class FileSnapshotDiff {
  List<String> get addedFiles;
  List<String> get deletedFiles;
  List<String> get modifiedFiles;

  factory FileSnapshotDiff({
    required Map<String, String> originalHashes,
    required Map<String, String> currentHashes,
  }) =>
      _FileSnapshotDiffImpl(
        originalHashes: originalHashes,
        currentHashes: currentHashes,
      );
}

extension SmartFileSnapshotDiff on FileSnapshotDiff {
  bool get hasChanges =>
      modifiedFiles.isNotEmpty ||
      addedFiles.isNotEmpty ||
      deletedFiles.isNotEmpty;
}

@immutable
final class _FileSnapshotDiffImpl implements FileSnapshotDiff {
  final Map<String, String> originalHashes;
  final Map<String, String> currentHashes;

  const _FileSnapshotDiffImpl({
    required this.originalHashes,
    required this.currentHashes,
  });

  @override
  List<String> get modifiedFiles => originalHashes.entries
      .where((e) =>
          currentHashes.containsKey(e.key) && currentHashes[e.key] != e.value)
      .map((e) => e.key)
      .toList();

  @override
  List<String> get deletedFiles =>
      originalHashes.keys.where((k) => !currentHashes.containsKey(k)).toList();

  @override
  List<String> get addedFiles =>
      currentHashes.keys.where((k) => !originalHashes.containsKey(k)).toList();
}
