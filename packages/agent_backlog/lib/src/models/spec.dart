import 'new_spec.dart';

/// Abstract interface contract representing a persisted spec item in a backlog.
///
/// Extends [NewSpec] with an auto-assigned [id] from storage.
abstract interface class Spec implements NewSpec {
  /// Creates a new [Spec] from a [NewSpec] and an [id].
  factory Spec.from(NewSpec newSpec, int id) => _Spec.fromNewSpec(newSpec, id);

  /// Creates a new [Spec] from a JSON map.
  factory Spec.fromJson(Map<String, dynamic> map) => _Spec.fromJson(map);

  /// The unique identifier of the spec.
  int get id;
}

extension SmartSpec on Spec {
  /// Returns true if the spec is done.
  bool get isDone => status == 'done';

  /// Returns true if the spec is pending.
  bool get isPending => status == 'pending';

  /// Returns true if the spec is in progress.
  bool get isInProgress => status == 'in_progress';

  /// Returns a new spec with the status set to 'done'
  Spec markedAsDone() => copyWith(status: 'done');

  /// Returns a new spec with the status set to 'pending'
  Spec markedAsPending() => copyWith(status: 'pending');

  /// Returns a new spec with the status set to 'in_progress'
  Spec markedAsInProgress() => copyWith(status: 'in_progress');

  /// Returns a copy of the spec with the specified fields updated
  Spec copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    Map<String, dynamic>? metadata,
  }) =>
      _SpecCopy(
        origin: this,
        methods: {
          if (id != null) #id: () => id,
          if (title != null) #title: () => title,
          if (description != null) #description: () => description,
          if (status != null) #status: () => status,
          if (metadata != null) #metadata: () => metadata,
        },
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'metadata': metadata,
      'description': description,
    };
  }
}

final class _SpecCopy implements Spec {
  _SpecCopy({
    required Spec origin,
    required Map<Symbol, Function> methods,
  })  : _origin = origin,
        _methods = Map.unmodifiable(methods);

  final Spec _origin;

  final Map<Symbol, Function> _methods;

  @override
  int get id => _method(#id)?.call() ?? _origin.id;

  @override
  String get title => _method(#title)?.call() ?? _origin.title;

  @override
  String get description =>
      _method(#description)?.call() ?? _origin.description;

  @override
  String get status => _method(#status)?.call() ?? _origin.status;

  @override
  Map<String, dynamic> get metadata =>
      _method(#metadata)?.call() ?? _origin.metadata;

  Function? _method(Symbol name) => _methods[name];
}

/// Internal implementation of [Spec] for YAML serialization.
final class _Spec implements Spec {
  _Spec.fromNewSpec(NewSpec spec, int newId)
      : id = newId,
        title = spec.title,
        status = spec.status,
        description = spec.description,
        metadata = Map<String, dynamic>.unmodifiable(spec.metadata);

  factory _Spec.fromJson(Map<String, dynamic> map) {
    return _Spec._raw(
      id: map['id'] as int? ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
    );
  }

  _Spec._raw({
    required this.id,
    required this.title,
    required this.status,
    required this.metadata,
    required this.description,
  });

  @override
  final int id;

  @override
  final String title;

  @override
  final String description;

  @override
  final String status;

  @override
  final Map<String, dynamic> metadata;
}
