import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

Matcher isSpec({
  Object? id = anything,
  Object? title = anything,
  Object? status = anything,
  Object? metadata = anything,
}) =>
    _SpecMatcher(
      id: wrapMatcher(id),
      title: wrapMatcher(title),
      status: wrapMatcher(status),
      metadata: wrapMatcher(metadata),
    );

Matcher equalsSpec(Spec expected) => isSpec(
      id: expected.id,
      title: expected.title,
      status: expected.status,
      metadata: expected.metadata,
    );

final class _SpecMatcher extends Matcher {
  final Matcher id;
  final Matcher title;
  final Matcher status;
  final Matcher metadata;

  _SpecMatcher({
    required this.id,
    required this.title,
    required this.status,
    required this.metadata,
  });

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Spec) return false;
    return id.matches(item.id, matchState) &&
        title.matches(item.title, matchState) &&
        status.matches(item.status, matchState) &&
        metadata.matches(item.metadata, matchState);
  }

  @override
  Description describe(Description description) {
    return description.add('a Spec matching properties');
  }
}
