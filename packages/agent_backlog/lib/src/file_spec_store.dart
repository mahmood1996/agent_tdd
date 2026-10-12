import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:resource/resource.dart';

import 'models/new_spec.dart';
import 'models/spec.dart';

import 'spec_store.dart';

/// [SpecStore] implementation that persists [Spec] list to YAML files on disk.
final class FileSpecStore implements SpecStore {
  FileSpecStore(String saveDir, String filePath)
      : _resource = YamlResource(File(p.join(saveDir, filePath)));

  final Resource<dynamic> _resource;

  @override
  Future<List<Spec>> specs() async {
    try {
      return await _tryGettingSavedSpecs();
    } on ResourceNotFoundException {
      return [];
    }
  }

  Future<List<Spec>> _tryGettingSavedSpecs() async {
    return List.from(await _resource.content() ?? [])
        .map(
          (item) => Spec.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  @override
  Future<void> addSpecs(Iterable<NewSpec> specs) async {
    final incoming = specs.toList();
    if (incoming.isEmpty) return;

    final currentSpecs = await this.specs();
    var nextId = currentSpecs.isEmpty
        ? 1
        : currentSpecs.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;

    await _resource.save([
      ...currentSpecs.map((t) => t.toJson()),
      ...incoming.map((spec) => Spec.from(spec, nextId++).toJson()),
    ]);
  }

  @override
  Future<void> updateSpecStatus(int specId, String newStatus) async {
    await _resource.save(
      (await specs())
          .map((s) => s.id == specId ? s.copyWith(status: newStatus) : s)
          .toList()
          .map((t) => t.toJson())
          .toList(),
    );
  }
}
