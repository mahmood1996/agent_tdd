import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'file_snapshot.dart';

/// Strategy implementation of [FileSnapshot] computing SHA-256 hashes from disk glob patterns
final class PatternFileSnapshot implements FileSnapshot {
  final List<String> patterns;
  final String? baseDir;

  const PatternFileSnapshot({
    required this.patterns,
    this.baseDir,
  });

  @override
  Future<Map<String, String>> hashes() async {
    final rootPath = baseDir ?? Directory.current.path;
    final rootDir = Directory(rootPath);
    final fileHashes = <String, String>{};

    if (!await rootDir.exists()) return const {};

    final globs = patterns.map((p) => Glob(p)).toList();

    final fallbackGlobs = patterns
        .where((p) => p.contains('/**/'))
        .map((p) => Glob(p.replaceAll('/**/', '/*')))
        .toList();

    await for (final entity in rootDir.list(recursive: true)) {
      if (entity is! File) continue;

      final relPath =
          p.relative(entity.path, from: rootPath).replaceAll('\\', '/');

      final isMatch = globs.any((g) => g.matches(relPath)) ||
          fallbackGlobs.any((g) => g.matches(relPath));

      if (isMatch) {
        final stream = entity.openRead();
        fileHashes[relPath] = (await sha256.bind(stream).first).toString();
      }
    }

    return fileHashes;
  }
}
