import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import '../../domain/models/config.dart';
import '../../domain/models/serializable_config.dart';
import '../../domain/stores/config_store.dart';
import '../models/json_config.dart';

/// A [ConfigStore] implementation that reads from and writes to a YAML file.
final class FileConfigStore implements ConfigStore {
  final File _file;

  /// Private constructor wrapping a [File].
  FileConfigStore._(this._file);

  /// Public constructor taking a file path string.
  FileConfigStore(String path) : this._(File(path));

  @override
  Future<Config?> config() async {
    if (!await _file.exists()) {
      return null;
    }

    final content = await _file.readAsString();
    if (content.trim().isEmpty) {
      return null;
    }

    final loadedYaml = loadYaml(content);
    if (loadedYaml is! Map) {
      return null;
    }

    final standardMap = _convertYamlToStandard(loadedYaml);
    if (standardMap is! Map<String, dynamic>) {
      return null;
    }

    final jsonString = jsonEncode(standardMap);
    return JsonConfig(jsonString);
  }

  @override
  Future<void> save(SerializableConfig conf) async {
    final map = conf.toMap();
    final yamlWriter = YamlWriter();
    final yamlString = yamlWriter.write(map);
    await _file.writeAsString(yamlString);
  }

  /// Converts YAML data structures (e.g. [YamlMap], [YamlList]) into standard Dart Maps/Lists.
  dynamic _convertYamlToStandard(dynamic node) {
    if (node is Map) {
      final map = <String, dynamic>{};
      node.forEach((key, value) {
        map[key.toString()] = _convertYamlToStandard(value);
      });
      return map;
    } else if (node is List) {
      return node.map(_convertYamlToStandard).toList();
    }
    return node;
  }
}
