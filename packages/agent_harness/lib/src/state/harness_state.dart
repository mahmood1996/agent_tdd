/// Value object representing active workflow state
final class HarnessState {
  final String phase;

  final String? nextCommand;

  final List<String> allowedCommands;

  final List<String> editablePatterns;

  final List<String> readOnlyPatterns;

  final Map<String, dynamic> metadata;

  const HarnessState({
    required this.phase,
    required this.editablePatterns,
    required this.readOnlyPatterns,
    this.nextCommand,
    this.allowedCommands = const [],
    this.metadata = const {},
  });

  HarnessState copyWith({
    String? phase,
    List<String>? editablePatterns,
    List<String>? readOnlyPatterns,
    String? nextCommand,
    List<String>? allowedCommands,
    Map<String, dynamic>? metadata,
  }) {
    return HarnessState(
      phase: phase ?? this.phase,
      editablePatterns: editablePatterns ?? this.editablePatterns,
      readOnlyPatterns: readOnlyPatterns ?? this.readOnlyPatterns,
      nextCommand: nextCommand ?? this.nextCommand,
      allowedCommands: allowedCommands ?? this.allowedCommands,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'editable_patterns': editablePatterns,
      'read_only_patterns': readOnlyPatterns,
      if (nextCommand != null) 'next_command': nextCommand,
      if (allowedCommands.isNotEmpty) 'allowed_commands': allowedCommands,
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
      allowedCommands: (json['allowed_commands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}
