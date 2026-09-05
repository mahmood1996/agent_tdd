import 'package:agent_harness/agent_harness.dart';

/// Convenience extensions and factories for TDD workflow states on [HarnessState].
extension TddStateExtensions on HarnessState {
  bool get isIdle => phase.toUpperCase() == 'IDLE';
  bool get isRed => phase.toUpperCase() == 'RED';
  bool get isGreen => phase.toUpperCase() == 'GREEN';
  bool get isRefactor => phase.toUpperCase() == 'REFACTOR';
  bool get isAlreadyPassed =>
      phase.toUpperCase() == 'ALREADY_PASSED' ||
      phase.toUpperCase() == 'ALREADYPASSED';

  int? get activeSpecId => (metadata['active_spec_id'] as num?)?.toInt();
  String? get activeSpecTitle => metadata['active_spec_title']?.toString();

  DateTime get startedAt =>
      DateTime.tryParse(metadata['started_at']?.toString() ?? '') ??
      DateTime.now();

  DateTime get lastUpdated =>
      DateTime.tryParse(metadata['last_updated']?.toString() ?? '') ??
      DateTime.now();
}

/// Helper factories for TDD phase [HarnessState] creation.
abstract final class TddHarnessState {
  static HarnessState idle() {
    final now = DateTime.now();
    return HarnessState(
      phase: 'IDLE',
      editablePatterns: const [],
      readOnlyPatterns: const [],
      nextCommand: 'agent-tdd next',
      allowedCommands: const [
        'agent-tdd next',
        'agent-tdd specs',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'started_at': now.toIso8601String(),
        'last_updated': now.toIso8601String(),
      },
    );
  }

  static HarnessState red({
    required int activeSpecId,
    required String activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    final now = DateTime.now();
    return HarnessState(
      phase: 'RED',
      editablePatterns: const ['test/**/*_test.dart'],
      readOnlyPatterns: const ['lib/**/*.dart'],
      nextCommand: 'agent-tdd verify-red',
      allowedCommands: const [
        'agent-tdd verify-red',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'active_spec_id': activeSpecId,
        'active_spec_title': activeSpecTitle,
        'started_at': (startedAt ?? now).toIso8601String(),
        'last_updated': (lastUpdated ?? now).toIso8601String(),
      },
    );
  }

  static HarnessState green({
    required int activeSpecId,
    required String activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    final now = DateTime.now();
    return HarnessState(
      phase: 'GREEN',
      editablePatterns: const ['lib/**/*.dart'],
      readOnlyPatterns: const ['test/**/*_test.dart'],
      nextCommand: 'agent-tdd verify-green',
      allowedCommands: const [
        'agent-tdd verify-green',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'active_spec_id': activeSpecId,
        'active_spec_title': activeSpecTitle,
        'started_at': (startedAt ?? now).toIso8601String(),
        'last_updated': (lastUpdated ?? now).toIso8601String(),
      },
    );
  }

  static HarnessState refactor({
    required int activeSpecId,
    required String activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    final now = DateTime.now();
    return HarnessState(
      phase: 'REFACTOR',
      editablePatterns: const ['lib/**/*.dart'],
      readOnlyPatterns: const ['test/**/*_test.dart'],
      nextCommand: 'agent-tdd verify-refactor',
      allowedCommands: const [
        'agent-tdd verify-refactor',
        'agent-tdd complete',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'active_spec_id': activeSpecId,
        'active_spec_title': activeSpecTitle,
        'started_at': (startedAt ?? now).toIso8601String(),
        'last_updated': (lastUpdated ?? now).toIso8601String(),
      },
    );
  }

  static HarnessState alreadyPassed({
    required int activeSpecId,
    required String activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    final now = DateTime.now();
    return HarnessState(
      phase: 'ALREADY_PASSED',
      editablePatterns: const [],
      readOnlyPatterns: const [],
      nextCommand: 'agent-tdd next',
      allowedCommands: const [
        'agent-tdd next',
        'agent-tdd specs',
        'agent-tdd status',
        'agent-tdd reset',
      ],
      metadata: {
        'active_spec_id': activeSpecId,
        'active_spec_title': activeSpecTitle,
        'started_at': (startedAt ?? now).toIso8601String(),
        'last_updated': (lastUpdated ?? now).toIso8601String(),
      },
    );
  }
}
