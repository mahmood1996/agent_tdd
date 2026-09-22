import 'file_snapshot.dart';

/// Strategy implementation of [FileSnapshot] holding in-memory hash mappings
final class MemoryFileSnapshot implements FileSnapshot {
  final Map<String, String> fileHashes;

  const MemoryFileSnapshot(this.fileHashes);

  @override
  Future<Map<String, String>> hashes() async => fileHashes;
}
