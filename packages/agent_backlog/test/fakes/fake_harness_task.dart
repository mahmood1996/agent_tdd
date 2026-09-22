import 'package:agent_backlog/agent_backlog.dart';

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
