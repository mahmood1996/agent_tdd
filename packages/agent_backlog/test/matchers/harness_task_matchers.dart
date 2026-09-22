import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

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
