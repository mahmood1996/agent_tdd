import 'analysis_issue.dart';

/// Pure abstract contract representing the overall result of a static analysis run.
abstract interface class AnalysisResult {
  /// Parses raw process [output] into an [AnalysisResult].
  factory AnalysisResult(
    String output, {
    bool isSuccess,
    bool failOnWarnings,
  }) = _DefaultAnalysisResult;

  /// Creates a clean result with no issues.
  factory AnalysisResult.clean() = _CleanAnalysisResult;

  bool get isClean;

  List<AnalysisIssue> get issues;
}

/// Constant clean result representation.
final class _CleanAnalysisResult implements AnalysisResult {
  const _CleanAnalysisResult();

  @override
  bool get isClean => true;

  @override
  List<AnalysisIssue> get issues => const [];
}

/// Private default implementation of [AnalysisResult] encapsulating parsing logic in the object.
final class _DefaultAnalysisResult implements AnalysisResult {
  _DefaultAnalysisResult(
    this._output, {
    bool isSuccess = true,
    bool failOnWarnings = false,
  })  : _failOnWarnings = failOnWarnings,
        _isSuccess = isSuccess;

  final String _output;
  final bool _isSuccess;
  final bool _failOnWarnings;

  late final List<AnalysisIssue> _issues = _parseIssues();

  @override
  List<AnalysisIssue> get issues => _issues;

  @override
  late final bool isClean = _computeIsClean();

  List<AnalysisIssue> _parseIssues() {
    final trimmed = _output.trim();

    if (trimmed.isEmpty) return const [];

    final parsed = _output
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && AnalysisIssue.canMatch(line))
        .map(AnalysisIssue.new)
        .toList();

    return (parsed.isEmpty && (trimmed.contains('error') || !_isSuccess))
        ? [AnalysisIssue(trimmed)]
        : List.unmodifiable(parsed);
  }

  bool _computeIsClean() {
    if (!_isSuccess) return false;
    if (_failOnWarnings) return issues.isEmpty;
    return issues.every((i) => i.severity != 'error');
  }
}
