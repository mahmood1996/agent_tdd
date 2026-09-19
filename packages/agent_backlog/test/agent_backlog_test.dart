import 'dart:io';
import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

final class FakeHarnessTask implements HarnessTask {
  const FakeHarnessTask({
    required this.id,
    required this.title,
    required this.status,
    this.metadata = const {},
  });

  @override
  final int id;

  @override
  final String title;

  @override
  final String status;

  @override
  final Map<String, dynamic> metadata;
}

void main() {
  group('SmartHarnessTask extension Tests', () {
    test('SmartHarnessTask getters, and copyWith', () {
      final task = const FakeHarnessTask(
        id: 1,
        title: 'Build authentication endpoint',
        status: 'pending',
      );

      expect(task.isPending, isTrue);
      expect(task.isDone, isFalse);
      expect(task.isInProgress, isFalse);

      final copy = task.copyWith(status: 'done');
      expect(copy.id, equals(1));
      expect(copy.title, equals('Build authentication endpoint'));
      expect(copy.isDone, isTrue);
      expect(copy.isPending, isFalse);
    });
  });

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

Matcher isHarnessTask({
  Object? id = anything,
  Object? title = anything,
  Object? status = anything,
  Object? metadata = anything,
}) =>
    _HarnessTaskMatcher(
      id: wrapMatcher(id),
      title: wrapMatcher(title),
      status: wrapMatcher(status),
      metadata: wrapMatcher(metadata),
    );

Matcher equalsHarnessTask(HarnessTask expected) => isHarnessTask(
      id: expected.id,
      title: expected.title,
      status: expected.status,
      metadata: expected.metadata,
    );

final class _HarnessTaskMatcher extends Matcher {
  final Matcher id;
  final Matcher title;
  final Matcher status;
  final Matcher metadata;

  _HarnessTaskMatcher({
    required this.id,
    required this.title,
    required this.status,
    required this.metadata,
  });

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! HarnessTask) return false;
    return id.matches(item.id, matchState) &&
        title.matches(item.title, matchState) &&
        status.matches(item.status, matchState) &&
        metadata.matches(item.metadata, matchState);
  }

  @override
  Description describe(Description description) {
    return description.add('a HarnessTask matching properties');
  }
}
