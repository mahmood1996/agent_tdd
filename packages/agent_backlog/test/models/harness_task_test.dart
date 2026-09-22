import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

import '../fakes/fake_harness_task.dart';

void main() {
  group('SmartHarnessTask extension Tests', () {
    test('SmartHarnessTask getters and copyWith', () {
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
}
