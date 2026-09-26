import 'models/harness_task.dart';

/// Abstract interface for task backlog storage and retrieval
abstract interface class TaskStore {
  /// Loads all tasks from persistent storage
  Future<List<HarnessTask>> tasks();

  /// Saves all tasks to persistent storage
  Future<void> saveTasks(List<HarnessTask> tasks);
}

/// Extension providing high-level helper methods on top of [TaskStore]
extension SmartTaskStore on TaskStore {
  /// Gets the next pending task, or null if all tasks are complete
  Future<HarnessTask?> nextPendingTask() async =>
      (await tasks()).where((t) => t.isPending).firstOrNull;

  /// Marks a specific task as done by ID and persists the change
  Future<void> markTaskDone(
    int taskId,
  ) async =>
      await saveTasks(
        (await tasks())
            .map((t) => t.id == taskId ? t.copyWith(status: 'done') : t)
            .toList(),
      );

  /// Updates the status of a specific task by ID and persists the change
  Future<void> updateTaskStatus(int taskId, String status) async =>
      await saveTasks(
        (await tasks())
            .map((t) => t.id == taskId ? t.copyWith(status: status) : t)
            .toList(),
      );
}
