import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../domain/spec_item.dart';

final class SpecStore {
  SpecStore({
    required String projectDir,
    String fileName = 'specs.yaml',
  })  : _fileName = fileName,
        _projectDir = projectDir;

  final String _fileName;

  final String _projectDir;

  Future<List<SpecItem>> specs() async {
    final file = _specsFile;
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final doc = loadYaml(content);
    if (doc is! Map || doc['specs'] is! List) return [];

    return (doc['specs'] as List).map((item) {
      if (item is Map) {
        return SpecItem.fromJson(Map<String, dynamic>.from(item));
      }
      throw Exception('Invalid spec item format in $_specsFile');
    }).toList();
  }

  Future<void> addSpec(String title, {String? description}) async {
    final currentSpecs = await specs();
    final nextId = currentSpecs.isEmpty
        ? 1
        : (currentSpecs.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = SpecItem(
      id: nextId,
      title: title,
      description: description,
      status: 'pending',
    );
    await _save([...currentSpecs, newItem]);
  }

  Future<void> updateSpecStatus(int id, String newStatus) async {
    final currentSpecs = await specs();
    bool found = false;
    final updatedSpecs = currentSpecs.map((spec) {
      if (spec.id == id) {
        found = true;
        return spec.copyWith(status: newStatus);
      }
      return spec;
    }).toList();

    if (found) {
      await _save(updatedSpecs);
    }
  }

  Future<void> importSpecsFrom(String markdownPath) async {
    final file = File(markdownPath);
    if (!await file.exists()) {
      throw Exception('Markdown file not found: $markdownPath');
    }

    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      final isPending =
          trimmed.startsWith('- [ ]') || trimmed.startsWith('* [ ]');
      final isDone = trimmed.startsWith('- [x]') || trimmed.startsWith('* [x]');

      if (!isPending && !isDone) continue;

      final title = trimmed.substring(5).trim();
      if (title.isEmpty) continue;

      await addSpec(title);
      if (isDone) {
        final currentSpecs = await specs();
        if (currentSpecs.isNotEmpty) {
          final lastSpec = currentSpecs.last;
          await updateSpecStatus(lastSpec.id, 'done');
        }
      }
    }
  }

  Future<void> _save(List<SpecItem> items) async {
    final buffer = StringBuffer()
      ..writeln('# agent-tdd Feature Specs Backlog')
      ..writeln('specs:');

    for (final spec in items) {
      buffer.writeln('  - id: ${spec.id}');
      buffer.writeln('    title: "${spec.title.replaceAll('"', '\\"')}"');
      if (spec.description != null && spec.description!.isNotEmpty) {
        buffer.writeln(
            '    description: "${spec.description!.replaceAll('"', '\\"')}"');
      }
      buffer.writeln('    status: ${spec.status}');
    }

    await _specsFile.writeAsString(buffer.toString());
    await _syncToMarkdown(items);
  }

  Future<void> _syncToMarkdown(List<SpecItem> items) async {
    final mdFile = File(p.join(_projectDir, 'specs.md'));
    final upperMdFile = File(p.join(_projectDir, 'SPECS.md'));

    final mdExists = await mdFile.exists();
    final upperExists = await upperMdFile.exists();

    if (!mdExists && !upperExists) return;

    final targetFile = mdExists ? mdFile : upperMdFile;
    final buffer = StringBuffer()
      ..writeln('# Specs Backlog')
      ..writeln();

    for (final spec in items) {
      final check = spec.status == 'done' ? '[x]' : '[ ]';
      buffer.writeln('- $check #${spec.id}: ${spec.title}');
    }

    await targetFile.writeAsString(buffer.toString());
  }

  File get _specsFile => File(p.join(_projectDir, _fileName));
}

extension SmartSpecStore on SpecStore {
  Future<Map<String, dynamic>> summary() async {
    final list = await specs();
    final total = list.length;
    final completed = list.where((s) => s.status == 'done').length;
    final percentage = total == 0 ? 0 : ((completed / total) * 100).round();
    final active = await activeSpec();

    return {
      'total': total,
      'completed': completed,
      'percentage': percentage,
      'active_spec': active?.toJson(),
      'specs': list.map((s) => s.toJson()).toList(),
    };
  }

  Future<SpecItem?> nextPendingSpec() async =>
      (await specs()).where((s) => s.status == 'pending').firstOrNull;

  Future<SpecItem?> activeSpec() async => (await specs())
      .where((s) => ['red', 'green', 'refactor', 'already_passed'].any((e) => s.status == e))
      .firstOrNull;
}
