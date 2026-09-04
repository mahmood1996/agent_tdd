enum TddPhase { idle, red, green, refactor, alreadyPassed }

final class TddState {
  final TddPhase phase;
  final int? activeSpecId;
  final String? activeSpecTitle;
  final DateTime startedAt;
  final DateTime lastUpdated;

  const TddState({
    required this.phase,
    this.activeSpecId,
    this.activeSpecTitle,
    required this.startedAt,
    required this.lastUpdated,
  });

  static const String stateFileName = '.agent_tdd_state.json';

  factory TddState.idle() => TddState(
        phase: TddPhase.idle,
        startedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

  TddState copyWith({
    TddPhase? phase,
    int? activeSpecId,
    String? activeSpecTitle,
    DateTime? startedAt,
    DateTime? lastUpdated,
  }) {
    return TddState(
      phase: phase ?? this.phase,
      activeSpecId: activeSpecId ?? this.activeSpecId,
      activeSpecTitle: activeSpecTitle ?? this.activeSpecTitle,
      startedAt: startedAt ?? this.startedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory TddState.fromJson(Map<String, dynamic> json) {
    final phaseStr = json['phase']?.toString().toLowerCase() ?? 'idle';
    TddPhase phase;
    switch (phaseStr) {
      case 'red':
        phase = TddPhase.red;
        break;
      case 'green':
        phase = TddPhase.green;
        break;
      case 'refactor':
        phase = TddPhase.refactor;
        break;
      case 'already_passed':
      case 'alreadypassed':
        phase = TddPhase.alreadyPassed;
        break;
      case 'idle':
      default:
        phase = TddPhase.idle;
    }

    return TddState(
      phase: phase,
      activeSpecId: json['active_spec_id'] as int?,
      activeSpecTitle: json['active_spec_title'] as String?,
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? '') ?? DateTime.now(),
      lastUpdated: DateTime.tryParse(json['last_updated']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase.name.toUpperCase(),
      'active_spec_id': activeSpecId,
      'active_spec_title': activeSpecTitle,
      'started_at': startedAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
