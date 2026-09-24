import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import '../file_snapshot/file_snapshot.dart';
import 'file_index.dart';

/// Concrete [FileIndex] that traverses the file system and computes
/// SHA-256 fingerprints for all files matching the given glob patterns.
final class DiskFileIndex implements FileIndex {
  const DiskFileIndex({
    required String baseDir,
  }) : _baseDir = baseDir;

  final String _baseDir;

  @override
  Future<FileSnapshot> snapshotOf(List<String> patterns) async {
    if (!await Directory(_baseDir).exists()) return FileSnapshot(const {});

    // Collect matched files across all patterns, deduplicated by relative path.
    // Uses a Map so overlapping patterns never hash the same file twice.
    final matched = <String, File>{};

    await for (final file in _matchedFiles(patterns)) {
      final relPath = p
          .relative(
            file.path,
            from: _baseDir,
          )
          .replaceAll('\\', '/');
      matched.putIfAbsent(relPath, () => file);
    }

    // Hash all matched files in parallel.
    return FileSnapshot(
      Map.fromEntries(
        await Future.wait(
          matched.entries.map((e) async {
            final hash =
                (await sha256.bind(e.value.openRead()).first).toString();
            return MapEntry(e.key, hash);
          }),
        ),
      ),
    );
  }

  /// Yields all [File]s matching [patterns] by delegating traversal to [Glob].
  /// Patterns are iterated sequentially; [Glob] handles matching internally.
  Stream<File> _matchedFiles(List<String> patterns) async* {
    for (final pattern in patterns) {
      yield* Glob(pattern)
          .list(root: _baseDir)
          .where((f) => f is File)
          .map((f) => File(f.path));
    }
  }
}
