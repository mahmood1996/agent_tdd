/// Value object representing differences between two file snapshots
final class FileSnapshotDiff {
  final List<String> modifiedFiles;
  final List<String> addedFiles;
  final List<String> deletedFiles;

  const FileSnapshotDiff({
    required this.modifiedFiles,
    required this.addedFiles,
    required this.deletedFiles,
  });

  bool get hasChanges =>
      modifiedFiles.isNotEmpty || addedFiles.isNotEmpty || deletedFiles.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'modified_files': modifiedFiles,
      'added_files': addedFiles,
      'deleted_files': deletedFiles,
      'has_changes': hasChanges,
    };
  }
}
