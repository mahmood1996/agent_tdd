import 'new_spec.dart';

/// A lazy, iterable collection of [NewSpec] items parsed from a markdown string.
///
/// Only checklist lines (`- [ ]` pending, `- [x]` done) become elements.
/// All other lines are silently dropped. Each element lazily parses its
/// fields on first access — specs that are never read are never parsed.
///
/// Markdown line format:
/// ```
/// - [ ] <title> | <description> | <key>:<value> <key>:<value>
/// ```
/// Description and metadata sections are optional.
///
/// Example:
/// ```dart
/// final specs = NewSpecs.fromMarkdown('''
///   - [ ] fizzBuzzFor(5) returns 'Buzz'
///   - [ ] fizzBuzzFor(3) returns 'Fizz' | Multiples of 3 | priority:high
///   - [x] add(1, 2) returns 3
/// ''');
/// await store.addSpecs(specs);
/// ```
final class NewSpecs extends Iterable<NewSpec> {
  /// Parses a full markdown content string into an iterable of [NewSpec] items.
  NewSpecs.fromMarkdown(String markdown) : _specs = _parse(markdown);

  final List<NewSpec> _specs;

  static final _checklistRe = RegExp(r'^[-*]\s+\[[ xX]\]');

  static bool _isChecklistLine(String line) =>
      _checklistRe.hasMatch(line.trim());

  static List<NewSpec> _parse(String markdown) {
    return markdown
        .split('\n')
        .where(_isChecklistLine)
        .map((line) => _LazyMarkdownSpec(line.trim()))
        .toList();
  }

  @override
  Iterator<NewSpec> get iterator => _specs.iterator;
}

// ---------------------------------------------------------------------------
// Internal implementation — not part of the public API
// ---------------------------------------------------------------------------

/// Lazily parses a single checklist line into [NewSpec] fields.
final class _LazyMarkdownSpec implements NewSpec {
  _LazyMarkdownSpec(this._rawLine);

  final String _rawLine;

  // Parsed once on first access to any field, then cached.
  late final _ParsedLine _parsed = _ParsedLine.from(_rawLine);

  @override
  String get title => _parsed.title;

  @override
  String get status => _parsed.status;

  @override
  String get description => _parsed.description;

  @override
  Map<String, dynamic> get metadata => _parsed.metadata;
}

/// Parses a single checklist line into its constituent fields.
///
/// Format: `- [ ] <title> | <description> | <key>:<value> <key>:<value>`
final class _ParsedLine {
  _ParsedLine({
    required this.title,
    required this.status,
    required this.description,
    required this.metadata,
  });

  final String title;
  final String status;
  final String description;
  final Map<String, dynamic> metadata;

  static final _pendingRe = RegExp(r'^[-*]\s+\[ \]\s+(.+)$');
  static final _doneRe = RegExp(r'^[-*]\s+\[[xX]\]\s+(.+)$');

  factory _ParsedLine.from(String rawLine) {
    final pending = _pendingRe.firstMatch(rawLine);
    final done = _doneRe.firstMatch(rawLine);

    final String body;
    final String status;

    if (pending != null) {
      body = pending.group(1)!.trim();
      status = 'pending';
    } else if (done != null) {
      body = done.group(1)!.trim();
      status = 'done';
    } else {
      body = rawLine.trim();
      status = 'pending';
    }

    final parts = body.split('|').map((p) => p.trim()).toList();

    return _ParsedLine(
      title: parts.isNotEmpty ? parts[0] : '',
      status: status,
      description: parts.length > 1 ? parts[1] : '',
      metadata: parts.length > 2 ? _parseMetadata(parts[2]) : const {},
    );
  }

  static Map<String, dynamic> _parseMetadata(String raw) {
    if (raw.trim().isEmpty) return const {};
    final result = <String, dynamic>{};
    for (final token in raw.trim().split(RegExp(r'\s+'))) {
      final colonIdx = token.indexOf(':');
      if (colonIdx <= 0) continue;
      final key = token.substring(0, colonIdx);
      final value = token.substring(colonIdx + 1);
      result[key] = value;
    }
    return result.isEmpty ? const {} : Map.unmodifiable(result);
  }
}
