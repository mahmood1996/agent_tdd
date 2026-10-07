import 'package:agent_backlog/agent_backlog.dart';

final class FakeSpec implements Spec {
  const FakeSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.metadata = const {},
  });

  @override
  final int id;

  @override
  final String title;

  @override
  final String description;

  @override
  final String status;

  @override
  final Map<String, dynamic> metadata;
}
