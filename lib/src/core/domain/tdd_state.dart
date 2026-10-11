import 'package:agent_backlog/agent_backlog.dart';

enum TddPhase { idle, red, green, refactor, alreadyPassed }

/// Pure abstract interface contract representing the state of a TDD cycle.
abstract interface class TddState {
  static const String stateFileName = '.agent_tdd_state.json';

  /// Idle state with no active spec (0 parameters).
  factory TddState.idle() = _TddStateImpl.idle;

  /// Starts RED phase with minimal domain data (takes only [Spec]).
  factory TddState.red(Spec spec) = _TddStateImpl.red;

  /// GREEN phase initialized with minimal domain data.
  factory TddState.green(Spec spec) = _TddStateImpl.green;

  /// REFACTOR phase initialized with minimal domain data.
  factory TddState.refactor(Spec spec) = _TddStateImpl.refactor;

  /// ALREADY_PASSED phase initialized with minimal domain data.
  factory TddState.alreadyPassed(Spec spec) = _TddStateImpl.alreadyPassed;

  /// Restores [TddState] from JSON map.
  factory TddState.fromJson(Map<String, dynamic> json) = _TddStateImpl.fromJson;

  // Pure getters
  TddPhase get phase;
  int? get activeSpecId;
  String? get activeSpecTitle;
  DateTime get startedAt;
  DateTime get lastUpdated;
}

/// Extension providing fluent state transitions, copyWith, and serialization.
extension SmartTddState on TddState {
  TddState toGreen() => copyWith(
        phase: TddPhase.green,
        lastUpdated: DateTime.now(),
      );

  TddState toRefactor() => copyWith(
        phase: TddPhase.refactor,
        lastUpdated: DateTime.now(),
      );

  TddState toAlreadyPassed() => copyWith(
        phase: TddPhase.alreadyPassed,
        lastUpdated: DateTime.now(),
      );

  TddState toIdle() => TddState.idle();

  TddState copyWith({
    TddPhase? phase,
    int? activeSpecId,
    String? activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    return _TddStateImpl._internal(
      phase: phase ?? this.phase,
      activeSpecId: activeSpecId ?? this.activeSpecId,
      activeSpecTitle: activeSpecTitle ?? this.activeSpecTitle,
      startedAt: startedAt ?? this.startedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'phase': phase.name.toUpperCase(),
        'active_spec_id': activeSpecId,
        'active_spec_title': activeSpecTitle,
        'started_at': startedAt.toIso8601String(),
        'last_updated': lastUpdated.toIso8601String(),
      };
}

/// Private concrete implementation
final class _TddStateImpl implements TddState {
  _TddStateImpl._internal({
    required this.phase,
    this.activeSpecId,
    this.activeSpecTitle,
    required this.startedAt,
    required this.lastUpdated,
  });

  _TddStateImpl.idle()
      : phase = TddPhase.idle,
        activeSpecId = null,
        activeSpecTitle = null,
        startedAt = DateTime.now(),
        lastUpdated = DateTime.now();

  _TddStateImpl.red(Spec spec)
      : phase = TddPhase.red,
        activeSpecId = spec.id,
        activeSpecTitle = spec.title,
        startedAt = DateTime.now(),
        lastUpdated = DateTime.now();

  _TddStateImpl.green(Spec spec)
      : phase = TddPhase.green,
        activeSpecId = spec.id,
        activeSpecTitle = spec.title,
        startedAt = DateTime.now(),
        lastUpdated = DateTime.now();

  _TddStateImpl.refactor(Spec spec)
      : phase = TddPhase.refactor,
        activeSpecId = spec.id,
        activeSpecTitle = spec.title,
        startedAt = DateTime.now(),
        lastUpdated = DateTime.now();

  _TddStateImpl.alreadyPassed(Spec spec)
      : phase = TddPhase.alreadyPassed,
        activeSpecId = spec.id,
        activeSpecTitle = spec.title,
        startedAt = DateTime.now(),
        lastUpdated = DateTime.now();

  factory _TddStateImpl.fromJson(Map<String, dynamic> json) {
    final phaseStr = json['phase']?.toString().toLowerCase() ?? 'idle';
    final phase = switch (phaseStr) {
      'red' => TddPhase.red,
      'green' => TddPhase.green,
      'refactor' => TddPhase.refactor,
      'already_passed' || 'alreadypassed' => TddPhase.alreadyPassed,
      _ => TddPhase.idle,
    };

    return _TddStateImpl._internal(
      phase: phase,
      activeSpecId: json['active_spec_id'] as int?,
      activeSpecTitle: json['active_spec_title'] as String?,
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? '') ??
          DateTime.now(),
      lastUpdated: DateTime.tryParse(json['last_updated']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  final TddPhase phase;

  @override
  final int? activeSpecId;

  @override
  final String? activeSpecTitle;

  @override
  final DateTime startedAt;

  @override
  final DateTime lastUpdated;
}
