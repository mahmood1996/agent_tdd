import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

class MemoryTaskStore implements TaskStore {
  List<HarnessTask> _tasks;

  MemoryTaskStore([List<HarnessTask>? initial])
      : _tasks = List.from(initial ?? []);

  @override
  Future<List<HarnessTask>> loadTasks() async => List.unmodifiable(_tasks);

  @override
  Future<void> saveTasks(List<HarnessTask> tasks) async {
    _tasks = List.from(tasks);
  }

  @override
  Future<HarnessTask?> getNextPendingTask() async {
    return _tasks.where((t) => t.isPending).firstOrNull;
  }

  @override
  Future<void> markTaskDone(int taskId) async {
    _tasks = _tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(status: 'done');
      }
      return t;
    }).toList();
  }

  @override
  Future<List<HarnessTask>> importFromMarkdown(String markdownContent) async {
    final parsed = MarkdownTaskParser.parse(markdownContent);
    _tasks.addAll(parsed);
    return _tasks;
  }
}

void main() {
  group('agent_backlog Tests', () {
    test('HarnessTask serialization and status getters', () {
      final task = const HarnessTask(
        id: 1,
        title: 'Build authentication endpoint',
        status: 'pending',
      );

      expect(task.isPending, isTrue);
      expect(task.isDone, isFalse);

      final json = task.toJson();
      expect(json['id'], equals(1));
      expect(json['status'], equals('pending'));

      final parsed = HarnessTask.fromJson(json);
      expect(parsed.title, equals('Build authentication endpoint'));
    });

    test('MarkdownTaskParser parses checkbox checklists', () {
      const markdown = '''
# TODO List
- [ ] Task 1: Add user login
- [x] Task 2: Setup database
- [ ] Task 3: Write API docs
''';

      final tasks = MarkdownTaskParser.parse(markdown);
      expect(tasks.length, equals(3));
      expect(tasks[0].title, equals('Task 1: Add user login'));
      expect(tasks[0].isPending, isTrue);
      expect(tasks[1].isDone, isTrue);
    });

    test('MemoryTaskStore workflow', () async {
      final store = MemoryTaskStore([
        const HarnessTask(id: 1, title: 'Item 1', status: 'pending'),
        const HarnessTask(id: 2, title: 'Item 2', status: 'pending'),
      ]);

      final next = await store.getNextPendingTask();
      expect(next?.id, equals(1));

      await store.markTaskDone(1);

      final nextAfterDone = await store.getNextPendingTask();
      expect(nextAfterDone?.id, equals(2));
    });
  });
}
