import 'package:meta/meta.dart';

import 'file_snapshot.dart';

/// Abstract interface representing differences between two file snapshots
abstract interface class FileSnapshotDiff {
  List<String> get addedFiles;
  List<String> get deletedFiles;
  List<String> get modifiedFiles;

  factory FileSnapshotDiff({
    required FileSnapshot original,
    required FileSnapshot current,
  }) =>
      _FileSnapshotDiffImpl(original: original, current: current);
}

extension SmartFileSnapshotDiff on FileSnapshotDiff {
  bool get hasChanges =>
      modifiedFiles.isNotEmpty ||
      addedFiles.isNotEmpty ||
      deletedFiles.isNotEmpty;
}

@immutable
final class _FileSnapshotDiffImpl implements FileSnapshotDiff {
  const _FileSnapshotDiffImpl({
    required FileSnapshot original,
    required FileSnapshot current,
  })  : _current = current,
        _original = original;

  final FileSnapshot _current;

  final FileSnapshot _original;

  @override
  List<String> get modifiedFiles => _original.filePaths
      .where((e) =>
          _current.containsFile(e) &&
          _current.fingerprint(e) != _original.fingerprint(e))
      .toList();

  @override
  List<String> get deletedFiles =>
      _original.filePaths.where((e) => !_current.containsFile(e)).toList();

  @override
  List<String> get addedFiles =>
      _current.filePaths.where((e) => !_original.containsFile(e)).toList();
}
