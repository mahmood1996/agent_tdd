/// Abstract interface contract representing a task or feature spec item in a backlog
abstract interface class HarnessTask {
  int get id;

  String get title;

  String get description;

  String get status;

  Map<String, dynamic> get metadata;
}

extension SmartHarnessTask on HarnessTask {
  bool get isDone => status == 'done';

  bool get isPending => status == 'pending';

  bool get isInProgress => status == 'in_progress';

  /// Returns a new task with the status set to 'done'
  HarnessTask markedAsDone() => copyWith(status: 'done');

  /// Returns a new task with the status set to 'pending'
  HarnessTask markedAsPending() => copyWith(status: 'pending');

  /// Returns a new task with the status set to 'in_progress'
  HarnessTask markedAsInProgress() => copyWith(status: 'in_progress');

  /// Returns a copy of the task with the specified fields updated
  HarnessTask copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    Map<String, dynamic>? metadata,
  }) =>
      _HarnessTaskCopy(
        origin: this,
        methods: {
          if (id != null) #id: () => id,
          if (title != null) #title: () => title,
          if (description != null) #description: () => description,
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
  String get description => _method(#description)?.call() ?? _origin.description;

  @override
  String get status => _method(#status)?.call() ?? _origin.status;

  @override
  Map<String, dynamic> get metadata =>
      _method(#metadata)?.call() ?? _origin.metadata;

  Function? _method(Symbol name) => _methods[name];
}
