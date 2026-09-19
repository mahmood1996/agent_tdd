/// Abstract interface contract representing a task or feature spec item in a backlog
abstract interface class HarnessTask {
  int get id;

  String get title;

  String get status;

  Map<String, dynamic> get metadata;
}

extension SmartHarnessTask on HarnessTask {
  bool get isDone => status == 'done';

  bool get isPending => status == 'pending';

  bool get isInProgress => status == 'in_progress';

  HarnessTask copyWith({
    int? id,
    String? title,
    String? status,
    Map<String, dynamic>? metadata,
  }) =>
      _HarnessTaskCopy(
        origin: this,
        methods: {
          if (id != null) #id: () => id,
          if (title != null) #title: () => title,
          if (status != null) #status: () => status,
          if (metadata != null) #metadata: () => metadata,
        },
      );
}

final class _HarnessTaskCopy implements HarnessTask {
  _HarnessTaskCopy({
    required HarnessTask origin,
    required Map<Symbol, Function> methods,
  })  : _origin = origin,
        _methods = Map.unmodifiable(methods);

  final HarnessTask _origin;

  final Map<Symbol, Function> _methods;

  @override
  int get id => _method(#id)?.call() ?? _origin.id;

  @override
  String get title => _method(#title)?.call() ?? _origin.title;

  @override
  String get status => _method(#status)?.call() ?? _origin.status;

  @override
  Map<String, dynamic> get metadata =>
      _method(#metadata)?.call() ?? _origin.metadata;

  Function? _method(Symbol name) => _methods[name];
}
