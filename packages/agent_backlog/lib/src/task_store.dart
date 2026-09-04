import 'harness_task.dart';

/// Abstract interface for task backlog storage and retrieval
abstract interface class TaskStore {
  /// Loads all tasks from persistent storage
  Future<List<HarnessTask>> loadTasks();

  /// Saves all tasks to persistent storage
  Future<void> saveTasks(List<HarnessTask> tasks);

  /// Gets the next pending task, or null if all tasks are complete
  Future<HarnessTask?> getNextPendingTask();

  /// Marks a specific task as done by ID
  Future<void> markTaskDone(int taskId);

  /// Imports pending tasks from markdown checklist content (- [ ] task)
  Future<List<HarnessTask>> importFromMarkdown(String markdownContent);
}
