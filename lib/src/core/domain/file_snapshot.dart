final class FileSnapshot {
  final Map<String, String> hashes; // relativePath -> sha256

  const FileSnapshot(this.hashes);

  factory FileSnapshot.fromJson(Map<String, dynamic> json) {
    final map = <String, String>{};
    json.forEach((key, value) {
      map[key] = value.toString();
    });
    return FileSnapshot(map);
  }

  Map<String, dynamic> toJson() => hashes;

  static const String snapshotFileName = '.agent_tdd_snapshot.json';

  List<String> verifyIntegrityAgainst(FileSnapshot current) {
    final violations = <String>[];

    // Check for modified or removed files
    hashes.forEach((relPath, originalHash) {
      final currentHash = current.hashes[relPath];
      if (currentHash == null) {
        violations.add('$relPath (DELETED)');
      } else if (currentHash != originalHash) {
        violations.add('$relPath (MODIFIED)');
      }
    });

    // Check for newly added test files
    current.hashes.forEach((relPath, _) {
      if (!hashes.containsKey(relPath)) {
        violations.add('$relPath (ADDED)');
      }
    });

    return violations;
  }
}
