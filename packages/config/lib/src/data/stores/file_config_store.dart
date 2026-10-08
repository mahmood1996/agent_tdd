import 'dart:io';

import 'package:resource/resource.dart';

import '../../domain/models/readable_config.dart';
import '../../domain/models/serializable_config.dart';
import '../../domain/stores/config_store.dart';
import '../models/json_config.dart';

/// A [ConfigStore] implementation that reads from and writes to a YAML file.
final class FileConfigStore implements ConfigStore {
  /// Public constructor taking a file path string.
  FileConfigStore(String path) : this._(YamlResource(File(path)));

  /// Private constructor wrapping a [Resource].
  FileConfigStore._(this._resource);

  final Resource<dynamic> _resource;

  @override
  Future<ReadableConfig> config() async {
    try {
      return switch (await _resource.content()) {
        final Map result => JsonConfig(Map<String, dynamic>.from(result)),
        _ => ReadableConfig.empty,
      };
    } on ResourceNotFoundException {
      return ReadableConfig.empty;
    }
  }

  @override
  Future<void> save(SerializableConfig conf) async =>
      await _resource.save(conf.toMap());
}
