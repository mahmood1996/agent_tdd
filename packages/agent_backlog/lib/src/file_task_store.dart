import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'models/harness_task.dart';
import 'task_store.dart';

/// [TaskStore] implementation that persists [HarnessTask] list to YAML files on disk.
final class FileTaskStore implements TaskStore {
  final String saveDir;
  final String filePath;

  FileTaskStore(this.saveDir, this.filePath);

  @override
  Future<List<HarnessTask>> tasks() async {
    try {
      return await _tryGettingSavedTasks();
    } on FileSystemException {
      return [];
    }
  }

  Future<List<HarnessTask>> _tryGettingSavedTasks() async {
    if (!await _file.exists()) return [];

    return List.from(loadYaml(await _file.readAsString()) ?? const [])
        .map(
          (item) => _HarnessTask.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveTasks(List<HarnessTask> tasks) async {
    await _createSaveDirIfNeeded(_file);

    final dataList = tasks.map((t) => _HarnessTask(t).toMap()).toList();

    final yamlString = YamlWriter(allowUnquotedStrings: true).write(dataList);

    await _file.writeAsString(yamlString);
  }

  Future<void> _createSaveDirIfNeeded(File file) async {
    if (await file.parent.exists()) return;

    await file.parent.create(recursive: true);
  }

  File get _file => File(p.join(saveDir, filePath));
}

/// Internal implementation of [HarnessTask] for YAML serialization.
final class _HarnessTask implements HarnessTask {
  _HarnessTask(HarnessTask task)
      : id = task.id,
        title = task.title,
        status = task.status,
        metadata = Map<String, dynamic>.unmodifiable(task.metadata);

  _HarnessTask.raw({
    required this.id,
    required this.title,
    required this.status,
    required this.metadata,
  });

  factory _HarnessTask.fromMap(Map<String, dynamic> map) {
    return _HarnessTask.raw(
      id: map['id'] as int? ?? 0,
      title: map['title']?.toString() ?? '',
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
  final String status;

  @override
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'status': status,
        'metadata': metadata,
      };
}
