/// Value object representing active workflow state
final class HarnessState {
  final String phase;
  final List<String> editablePatterns;
  final List<String> readOnlyPatterns;
  final String? nextCommand;
  final Map<String, dynamic> metadata;

  const HarnessState({
    required this.phase,
    required this.editablePatterns,
    required this.readOnlyPatterns,
    this.nextCommand,
    this.metadata = const {},
  });

  HarnessState copyWith({
    String? phase,
    List<String>? editablePatterns,
    List<String>? readOnlyPatterns,
    String? nextCommand,
    Map<String, dynamic>? metadata,
  }) {
    return HarnessState(
      phase: phase ?? this.phase,
      editablePatterns: editablePatterns ?? this.editablePatterns,
      readOnlyPatterns: readOnlyPatterns ?? this.readOnlyPatterns,
      nextCommand: nextCommand ?? this.nextCommand,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'editable_patterns': editablePatterns,
      'read_only_patterns': readOnlyPatterns,
      if (nextCommand != null) 'next_command': nextCommand,
      'metadata': metadata,
    };
  }

  factory HarnessState.fromJson(Map<String, dynamic> json) {
    return HarnessState(
      phase: json['phase']?.toString() ?? 'IDLE',
      editablePatterns: (json['editable_patterns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      readOnlyPatterns: (json['read_only_patterns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      nextCommand: json['next_command']?.toString(),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
