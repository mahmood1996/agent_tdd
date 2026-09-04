final class ExecutableProcessResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final int durationMs;

  const ExecutableProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.durationMs,
  });

  String get combinedOutput => '$stdout\n$stderr'.trim();

  bool get isSuccess => exitCode == 0;
}
