import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

import '../fakes/fake_spec.dart';

void main() {
  group('SmartSpec extension Tests', () {
    test('SmartSpec getters and copyWith', () {
      final spec = const FakeSpec(
        id: 1,
        title: 'Build authentication endpoint',
        description: 'Implement login and register',
        status: 'pending',
      );

      expect(spec.isPending, isTrue);
      expect(spec.isDone, isFalse);
      expect(spec.isInProgress, isFalse);

      final copy = spec.copyWith(status: 'done');
      expect(copy.id, equals(1));
      expect(copy.title, equals('Build authentication endpoint'));
      expect(copy.isDone, isTrue);
      expect(copy.isPending, isFalse);
    });
  });
}
