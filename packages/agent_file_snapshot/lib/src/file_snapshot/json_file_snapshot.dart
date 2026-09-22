import 'dart:convert';
import 'dart:io';

import 'file_snapshot.dart';

/// Strategy implementation of [FileSnapshot] loading hashes from a JSON file source
final class JsonFileSnapshot implements FileSnapshot {
  final File jsonFile;

  const JsonFileSnapshot(this.jsonFile);

  @override
  Future<Map<String, String>> hashes() async {
    try {
      return !await jsonFile.exists()
          ? const {}
          : switch (jsonDecode(await jsonFile.readAsString())) {
              {'file_hashes': final map} when (map is Map<String, dynamic>) =>
                map.map((k, v) => MapEntry(k, v.toString())),
              final json => {
                  for (final e in json.entries) e.key: e.value.toString(),
                },
            };
    } catch (_) {
      return const {};
    }
  }
}
