/// Pure abstract contract representing an issue identified by static analysis.
abstract interface class AnalysisIssue {
  /// Creates an [AnalysisIssue] by delegating to the private default implementation.
  factory AnalysisIssue(String line) = _DefaultAnalysisIssue;

  static final _allPatterns = [
    _DartAnalysisIssue.pattern,
    _GenericAnalysisIssue.pattern,
    _SimpleAnalysisIssue.pattern,
  ];

  /// Helper to test if a line matches any recognized issue pattern.
  static bool canMatch(String line) {
    final trimmed = line.trim();

    return _allPatterns.any((pattern) => pattern.hasMatch(trimmed));
  }

  String get severity;
  String? get file;
  int? get line;
  int? get column;
  String get message;
}

extension SmartAnalysisIssue on AnalysisIssue {
  Map<String, dynamic> toJson() => {
        'severity': severity,
        if (file != null) 'file': file,
        if (line != null) 'line': line,
        if (column != null) 'column': column,
        'message': message,
      };
}

/// Private default implementation of [AnalysisIssue] encapsulating the dispatch table.
final class _DefaultAnalysisIssue implements AnalysisIssue {
  _DefaultAnalysisIssue(this._line);

  final String _line;

  late final AnalysisIssue _delegate = _resolve();

  AnalysisIssue _resolve() {
    final trimmed = _line.trim();
    return _matchers.entries.map((entry) {
      final match = entry.key.firstMatch(trimmed);
      return match != null ? entry.value(match) : null;
    }).firstWhere(
      (issue) => issue != null,
      orElse: () => _SimpleAnalysisIssue(trimmed),
    )!;
  }

  static final Map<RegExp, AnalysisIssue Function(Match)> _matchers = {
    _DartAnalysisIssue.pattern: _DartAnalysisIssue.new,
    _GenericAnalysisIssue.pattern: _GenericAnalysisIssue.new,
  };

  @override
  String get severity => _delegate.severity;

  @override
  String? get file => _delegate.file;

  @override
  int? get line => _delegate.line;

  @override
  int? get column => _delegate.column;

  @override
  String get message => _delegate.message;
}

/// Concrete issue for Dart analyze output format:
/// `warning • Unused import • lib/foo.dart:12:3`
final class _DartAnalysisIssue implements AnalysisIssue {
  _DartAnalysisIssue(Match match)
      : severity = match.group(1)!.toLowerCase(),
        message = match.group(2)!,
        file = match.group(3)!,
        line = int.tryParse(match.group(4)!),
        column = int.tryParse(match.group(5)!);

  static final pattern = RegExp(
    r'^\s*(info|warning|error)\s+•\s+(.+?)\s+•\s+(.+?):(\d+):(\d+)',
    caseSensitive: false,
  );

  @override
  final String severity;

  @override
  final String? file;

  @override
  final int? line;

  @override
  final int? column;

  @override
  final String message;
}

/// Concrete issue for generic compiler / linter format:
/// `src/validator.ts:14:5: error: Unused variable tempBuffer`
final class _GenericAnalysisIssue implements AnalysisIssue {
  _GenericAnalysisIssue(Match match)
      : file = match.group(1)!,
        line = int.tryParse(match.group(2)!),
        column = int.tryParse(match.group(3)!),
        severity = (match.group(4) ?? 'error').toLowerCase(),
        message = match.group(5)!;

  static final pattern = RegExp(
    r'^(.+?):(\d+):(\d+):\s*(?:(error|warning|info)(?::\s*|\s+))?(.+)',
    caseSensitive: false,
  );

  @override
  final String severity;

  @override
  final String? file;

  @override
  final int? line;

  @override
  final int? column;

  @override
  final String message;
}

/// Concrete issue for simple key-value format (`error: message`) and fallback.
final class _SimpleAnalysisIssue implements AnalysisIssue {
  _SimpleAnalysisIssue(this._line);

  final String _line;

  static final pattern = RegExp(
    r'(error|warning)\s*:\s*(.+)',
    caseSensitive: false,
  );

  late final Match? _match = pattern.firstMatch(_line);

  @override
  String get severity => _match?.group(1)?.toLowerCase() ?? 'error';

  @override
  String? get file => null;

  @override
  int? get line => null;

  @override
  int? get column => null;

  @override
  String get message => _match?.group(2) ?? _line.trim();
}
