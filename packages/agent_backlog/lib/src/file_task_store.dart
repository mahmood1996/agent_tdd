import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'models/harness_task.dart';
import 'task_store.dart';

/// [TaskStore] implementation that persists [HarnessTask] list to JSON files on disk.
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

    final content = await _file.readAsString();

    final list = jsonDecode(content) as List<dynamic>;

    return list
        .map((item) => _HarnessTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTasks(List<HarnessTask> tasks) async {
    await _createSaveDirIfNeeded(_file);

    final jsonList = tasks.map((t) => _HarnessTask(t).toJson()).toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    await _file.writeAsString(jsonString);
  }

  Future<void> _createSaveDirIfNeeded(File file) async {
    if (await file.parent.exists()) return;

    await file.parent.create(recursive: true);
  }

  File get _file => File(p.join(saveDir, filePath));
}

/// Internal implementation of [HarnessTask] for JSON serialization.
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

  factory _HarnessTask.fromJson(Map<String, dynamic> json) {
    return _HarnessTask.raw(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'metadata': metadata,
      };
}
