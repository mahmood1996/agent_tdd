import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

import 'fakes/fake_harness_task.dart';
import 'matchers/harness_task_matchers.dart';

void main() {
  group('FileTaskStore Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_task_store_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('tasks retrieves tasks saved by saveTasks', () async {
      final store = FileTaskStore(tempDir.path, 'tasks.json');
      final originalTasks = [
        const FakeHarnessTask(
          id: 1,
          title: 'Task 1',
          status: 'pending',
          metadata: {'meta': 'val'},
        ),
        const FakeHarnessTask(
          id: 2,
          title: 'Task 2',
          status: 'done',
        ),
      ];

      await store.saveTasks(originalTasks);
      final retrievedTasks = await store.tasks();

      expect(retrievedTasks.length, equals(2));
      expect(retrievedTasks[0], equalsHarnessTask(originalTasks[0]));
      expect(retrievedTasks[1], equalsHarnessTask(originalTasks[1]));
    });

    test('tasks returns empty list if file does not exist', () async {
      final store = FileTaskStore(tempDir.path, 'non_existent.json');
      final tasks = await store.tasks();
      expect(tasks, isEmpty);
    });

    test('FileTaskStore workflow with SmartTaskStore extension', () async {
      final store = FileTaskStore(tempDir.path, 'tasks.json');
      await store.saveTasks([
        const FakeHarnessTask(id: 1, title: 'Item 1', status: 'pending'),
        const FakeHarnessTask(id: 2, title: 'Item 2', status: 'pending'),
      ]);

      final next = await store.nextPendingTask();
      expect(next?.id, equals(1));

      await store.markTaskDone(1);

      final nextAfterDone = await store.nextPendingTask();
      expect(nextAfterDone?.id, equals(2));
    });
  });
}
