import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'models/spec.dart';
import 'spec_store.dart';

/// [SpecStore] implementation that persists [Spec] list to YAML files on disk.
final class FileSpecStore implements SpecStore {
  final String saveDir;
  final String filePath;

  FileSpecStore(this.saveDir, this.filePath);

  @override
  Future<List<Spec>> specs() async {
    try {
      return await _tryGettingSavedSpecs();
    } on FileSystemException {
      return [];
    }
  }

  Future<List<Spec>> _tryGettingSavedSpecs() async {
    return !await _file.exists()
        ? const <Spec>[]
        : List.from(loadYaml(await _file.readAsString()) ?? const [])
            .map(
              (item) => _Spec.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
  }

  @override
  Future<void> saveSpecs(List<Spec> specs) async {
    await _createSaveDirIfNeeded(_file);

    final dataList = specs.map((t) => _Spec(t).toMap()).toList();

    await _file.writeAsString(
      YamlWriter(
        allowUnquotedStrings: true,
      ).write(dataList),
    );
  }

  Future<void> _createSaveDirIfNeeded(File file) async {
    if (await file.parent.exists()) return;

    await file.parent.create(recursive: true);
  }

  File get _file => File(p.join(saveDir, filePath));
}

/// Internal implementation of [Spec] for YAML serialization.
final class _Spec implements Spec {
  _Spec(Spec spec)
      : id = spec.id,
        title = spec.title,
        status = spec.status,
        description = spec.description,
        metadata = Map<String, dynamic>.unmodifiable(spec.metadata);

  _Spec.raw({
    required this.id,
    required this.title,
    required this.status,
    required this.metadata,
    required this.description,
  });

  factory _Spec.fromMap(Map<String, dynamic> map) {
    return _Spec.raw(
      id: map['id'] as int? ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
    );
  }

  @override
  final int id;

  @override
  final String title;

  @override
  final String description;

  @override
  final String status;

  @override
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'status': status,
        'metadata': metadata,
        'description': description,
      };
}
