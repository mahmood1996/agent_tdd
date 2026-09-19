/// Abstract interface contract representing active workflow state
abstract interface class HarnessState {
  String get phase;

  String? get nextCommand;

  Map<String, dynamic> get extra;

  List<String> get editablePatterns;

  List<String> get readOnlyPatterns;
}

extension SmartHarnessState on HarnessState {
  HarnessState copyWith({
    String? phase,
    String? nextCommand,
    Map<String, dynamic>? extra,
    List<String>? editablePatterns,
    List<String>? readOnlyPatterns,
  }) =>
      _HarnessStateCopy(
        origin: this,
        methods: {
          if (phase != null) #phase: () => phase,
          if (extra != null) #extra: () => extra,
          if (nextCommand != null) #nextCommand: () => nextCommand,
          if (editablePatterns != null)
            #editablePatterns: () => editablePatterns,
          if (readOnlyPatterns != null)
            #readOnlyPatterns: () => readOnlyPatterns,
        },
      );

  Map<String, dynamic> toSuccessJson(String message) {
    return {
      'success': true,
      'message': message,
      'phase': phase,
      'allowed_actions': {
        'editable_files': editablePatterns,
        'read_only_files': readOnlyPatterns,
        if (nextCommand != null) 'next_command': nextCommand,
      },
      'instructions_for_agent': message,
    };
  }

  Map<String, dynamic> toFailureJson(String error) {
    return {
      'success': false,
      'error': error,
      'phase': phase,
      'allowed_actions': {
        'editable_files': editablePatterns,
        'read_only_files': readOnlyPatterns,
        if (nextCommand != null) 'next_command': nextCommand,
      },
      'instructions_for_agent': 'Fix error: $error',
    };
  }
}

final class _HarnessStateCopy implements HarnessState {
  _HarnessStateCopy({
    required HarnessState origin,
    required Map<Symbol, Function> methods,
  })  : _origin = origin,
        _methods = Map.unmodifiable(methods);

  final HarnessState _origin;

  final Map<Symbol, Function> _methods;

  @override
  String get phase => _method(#phase)?.call() ?? _origin.phase;

  @override
  String? get nextCommand =>
      _method(#nextCommand)?.call() ?? _origin.nextCommand;

  @override
  List<String> get editablePatterns =>
      _method(#editablePatterns)?.call() ?? _origin.editablePatterns;

  @override
  List<String> get readOnlyPatterns =>
      _method(#readOnlyPatterns)?.call() ?? _origin.readOnlyPatterns;

  @override
  Map<String, dynamic> get extra => _method(#extra)?.call() ?? _origin.extra;

  Function? _method(Symbol name) => _methods[name];
}
