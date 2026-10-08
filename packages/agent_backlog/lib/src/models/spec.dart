import 'dart:convert';

/// Abstract interface contract representing a task or feature spec item in a backlog
abstract interface class Spec {
  int get id;

  String get title;

  String get description;

  String get status;

  Map<String, dynamic> get metadata;

  /// Creates a lazy [Spec] by parsing a markdown checklist string.
  factory Spec.fromMarkdown(String raw) => _CachedSpec(MarkdownSpec(raw));
}

extension SmartSpec on Spec {
  bool get isDone => status == 'done';

  bool get isPending => status == 'pending';

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

/// A lazy, resilient implementation of [Spec] that parses a markdown checklist line.
///
/// Parsing is completely deferred: each getter independently extracts and caches
/// only its required data from [_raw] when accessed.
final class MarkdownSpec implements Spec {
  /// Constructs a [MarkdownSpec] from a raw markdown string.
  MarkdownSpec(String raw) : _raw = raw;

  final String _raw;

  @override
  late final int id = _parseId(_raw);

  @override
  late final String status = _parseStatus(_raw);

  @override
  late final String title = _parseTitle(_raw);

  @override
  late final String description = _parseDescription(_raw);

  @override
  late final Map<String, dynamic> metadata = _parseMetadata(_raw);

  static final RegExp _statusRegex = RegExp(r'^\s*[-*+]\s*\[([ xX\/\-]?)\]');
  static final RegExp _idRegex = RegExp(r'^\s*[-*+]\s*\[[ xX\/\-]?\]\s*#(\d+)');
  static final RegExp _metadataRegex =
      RegExp(r'(?:<!--\s*(\{.*?\})\s*-->|(?:\s|^)(\{.*?\})\s*$)');

  String _parseStatus(String raw) {
    return switch (_statusRegex.firstMatch(raw)) {
      null => 'pending',
      final match => switch (match.group(1)?.trim()) {
          'x' || 'X' => 'done',
          '/' || '-' => 'in_progress',
          ' ' || '' || null => 'pending',
          _ => 'pending',
        }
    };
  }

  int _parseId(String raw) {
    final match = _idRegex.firstMatch(raw);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  String _parseTitle(String raw) {
    return raw
        .replaceFirst(_metadataRegex, '')
        .replaceFirst(RegExp(r'::.*$'), '')
        .replaceFirst(_statusRegex, '')
        .trim()
        .replaceFirst(RegExp(r'^#\d+\s*'), '')
        .trim();
  }

  String _parseDescription(String raw) {
    final withoutMeta = raw.replaceFirst(_metadataRegex, '');
    final match = RegExp(r'::\s*(.*)$').firstMatch(withoutMeta);
    return match != null ? match.group(1)!.trim() : '';
  }

  Map<String, dynamic> _parseMetadata(String raw) {
    try {
      return _tryParseMetadata(raw);
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic> _tryParseMetadata(String raw) {
    return switch (_metadataRegex.firstMatch(raw)) {
      null => const {},
      final match => switch (match.group(1) ?? match.group(2)) {
          null => const {},
          final jsonStr => switch (jsonDecode(jsonStr)) {
              final Map decoded => Map<String, dynamic>.unmodifiable(decoded),
              _ => const {}
            },
        }
    };
  }
}

/// Caches the results of [Spec] calls.
final class _CachedSpec implements Spec {
  _CachedSpec(this._origin) : _cache = {};

  final Spec _origin;

  final Map<String, dynamic> _cache;

  @override
  String get description => _cache['description'] ??= _origin.description;

  @override
  int get id => _cache['id'] ??= _origin.id;

  @override
  Map<String, dynamic> get metadata => _cache['metadata'] ??= _origin.metadata;

  @override
  String get status => _cache['status'] ??= _origin.status;

  @override
  String get title => _cache['title'] ??= _origin.title;
}
