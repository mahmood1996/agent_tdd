import 'dart:io' show ProcessResult;

/// Interface representing the result of an executed process.
abstract interface class ExecutableProcessResult {
  int get exitCode;
  String get stdout;
  String get stderr;

  /// Canonical factory constructor that takes a dart:io [ProcessResult].
  factory ExecutableProcessResult(ProcessResult result) =
      _ExecutableProcessResult;
}

/// Convenience extensions for [ExecutableProcessResult].
extension ExecutableProcessResultX on ExecutableProcessResult {
  String get combinedOutput => '${this.stdout}\n${this.stderr}'.trim();

  bool get isSuccess => this.exitCode == 0;
}

final class _ExecutableProcessResult implements ExecutableProcessResult {
  @override
  final int exitCode;
  @override
  final String stdout;
  @override
  final String stderr;

  _ExecutableProcessResult(ProcessResult result)
      : exitCode = result.exitCode,
        stdout = result.stdout.toString(),
        stderr = result.stderr.toString();
}
