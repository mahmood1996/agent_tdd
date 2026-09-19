import 'dart:io';
import 'package:agent_harness/agent_harness.dart';
import 'package:test/test.dart';

void main() {
  group('FileStateStore', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_state_store_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'savedState retrieves state saved by saveState',
      () async {
        final store = FileStateStore(tempDir.path, 'state.json');
        final originalState = FakeHarnessState(
          phase: 'GREEN',
          editablePatterns: ['lib/src/foo.dart'],
          readOnlyPatterns: ['test/foo_test.dart'],
          nextCommand: 'agent-tdd complete',
          extra: {'key': 'value'},
        );

        await store.saveState(originalState);
        final retrievedState = await store.savedState();

        expect(retrievedState, equalsHarnessState(originalState));
      },
    );

    test(
      'savedState returns empty HarnessState if file does not exist',
      () async {
        final store = FileStateStore(tempDir.path, 'non_existent.json');

        final state = await store.savedState();

        expect(
          state,
          isHarnessState(
            phase: isEmpty,
            editablePatterns: isEmpty,
            readOnlyPatterns: isEmpty,
            nextCommand: isNull,
            extra: isEmpty,
          ),
        );
      },
    );
  });
}

Matcher isHarnessState({
  Object? phase = anything,
  Object? editablePatterns = anything,
  Object? readOnlyPatterns = anything,
  Object? nextCommand = anything,
  Object? extra = anything,
}) =>
    _HarnessStateMatcher(
      phase: wrapMatcher(phase),
      editablePatterns: wrapMatcher(editablePatterns),
      readOnlyPatterns: wrapMatcher(readOnlyPatterns),
      nextCommand: wrapMatcher(nextCommand),
      extra: wrapMatcher(extra),
    );

Matcher equalsHarnessState(HarnessState expected) => isHarnessState(
      phase: expected.phase,
      editablePatterns: expected.editablePatterns,
      readOnlyPatterns: expected.readOnlyPatterns,
      nextCommand: expected.nextCommand,
      extra: expected.extra,
    );

final class _HarnessStateMatcher extends Matcher {
  final Matcher phase;
  final Matcher editablePatterns;
  final Matcher readOnlyPatterns;
  final Matcher nextCommand;
  final Matcher extra;

  _HarnessStateMatcher({
    required this.phase,
    required this.editablePatterns,
    required this.readOnlyPatterns,
    required this.nextCommand,
    required this.extra,
  });

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! HarnessState) return false;
    return phase.matches(item.phase, matchState) &&
        editablePatterns.matches(item.editablePatterns, matchState) &&
        readOnlyPatterns.matches(item.readOnlyPatterns, matchState) &&
        nextCommand.matches(item.nextCommand, matchState) &&
        extra.matches(item.extra, matchState);
  }

  @override
  Description describe(Description description) {
    return description.add('a HarnessState matching properties');
  }
}

final class FakeHarnessState implements HarnessState {
  const FakeHarnessState({
    required this.phase,
    required this.editablePatterns,
    required this.readOnlyPatterns,
    this.nextCommand,
    this.extra = const {},
  });

  @override
  final String phase;

  @override
  final String? nextCommand;

  @override
  final Map<String, dynamic> extra;

  @override
  final List<String> editablePatterns;

  @override
  final List<String> readOnlyPatterns;
}
