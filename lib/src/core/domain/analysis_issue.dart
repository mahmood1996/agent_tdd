import 'executable_process_result.dart';

final class AnalysisIssue {
  final String severity; // error, warning, info
  final String? file;
  final int? line;
  final int? column;
  final String message;

  const AnalysisIssue({
    required this.severity,
    this.file,
    this.line,
    this.column,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      if (file != null) 'file': file,
      if (line != null) 'line': line,
      if (column != null) 'column': column,
      'message': message,
    };
  }
}

final class AnalysisResult {
  final bool isClean;
  final List<AnalysisIssue> issues;
  final ExecutableProcessResult rawResult;

  const AnalysisResult({
    required this.isClean,
    required this.issues,
    required this.rawResult,
  });
}
