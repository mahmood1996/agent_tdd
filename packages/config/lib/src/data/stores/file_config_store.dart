import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../domain/models/readable_config.dart';
import '../../domain/models/serializable_config.dart';
import '../../domain/stores/config_store.dart';
import '../models/json_config.dart';

/// A [ConfigStore] implementation that reads from and writes to a YAML file.
final class FileConfigStore implements ConfigStore {
  /// Public constructor taking a file path string.
  FileConfigStore(String path) : this._(File(path));

  /// Private constructor wrapping a [File].
  FileConfigStore._(this._file);

  final File _file;

  @override
  Future<ReadableConfig?> config() async {
    return !await _file.exists()
        ? null
        : switch ((await _file.readAsString()).trim()) {
            '' => null,
            final content => switch (loadYaml(content)) {
              final Map result => JsonConfig(jsonEncode(result)),
              _ => null,
            },
          };
  }

  @override
  Future<void> save(SerializableConfig conf) async {
    final map = conf.toMap();
    final yamlWriter = YamlWriter();
    final yamlString = yamlWriter.write(map);
    await _file.writeAsString(yamlString);
  }
}
