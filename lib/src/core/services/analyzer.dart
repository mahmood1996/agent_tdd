import '../data/config_store.dart';
import '../domain/analysis_issue.dart';
import '../domain/executable_process_result.dart';
import 'processes.dart';

class Analyzer {
  final String projectDir;
  final ConfigStore configStore;
  final Processes processes;

  Analyzer({
    required this.projectDir,
    ConfigStore? configStore,
    Processes? processes,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        processes = processes ?? Processes(projectDir);

  Future<AnalysisResult> analysisResult() async {
    final config = await configStore.config();
    final cmd = config.analyzeCommand;
    if (cmd == null || cmd.isEmpty) {
      return AnalysisResult(
        isClean: true,
        issues: [],
        rawResult: const ExecutableProcessResult(
            exitCode: 0,
            stdout: 'No analyze_command configured.',
            stderr: '',
            durationMs: 0),
      );
    }

    ExecutableProcessResult? res;

    await processes.process(cmd).execute(onFinished: (result) => res = result);

    final result = res!;
    final issues = _issuesIn(result.combinedOutput);
    final isClean = result.isSuccess &&
        (config.failOnWarnings
            ? issues.isEmpty
            : issues.every((i) => i.severity != 'error'));

    return AnalysisResult(
      isClean: isClean,
      issues: issues,
      rawResult: result,
    );
  }

  List<AnalysisIssue> _issuesIn(String output) {
    final issues = <AnalysisIssue>[];
    final lines = output.split('\n');

    final dartPattern = RegExp(
        r'^\s*(info|warning|error)\s+•\s+(.+?)\s+•\s+(.+?):(\d+):(\d+)',
        caseSensitive: false);
    final genericPattern = RegExp(
        r'^(.+?):(\d+):(\d+):\s*(error|warning|info)?\s*(.+)',
        caseSensitive: false);
    final simplePattern =
        RegExp(r'(error|warning)\s*:\s*(.+)', caseSensitive: false);

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final dartMatch = dartPattern.firstMatch(trimmed);
      if (dartMatch != null) {
        issues.add(AnalysisIssue(
          severity: dartMatch.group(1)!.toLowerCase(),
          message: dartMatch.group(2)!,
          file: dartMatch.group(3)!,
          line: int.tryParse(dartMatch.group(4)!),
          column: int.tryParse(dartMatch.group(5)!),
        ));
        continue;
      }

      final genericMatch = genericPattern.firstMatch(trimmed);
      if (genericMatch != null) {
        issues.add(AnalysisIssue(
          file: genericMatch.group(1)!,
          line: int.tryParse(genericMatch.group(2)!),
          column: int.tryParse(genericMatch.group(3)!),
          severity: (genericMatch.group(4) ?? 'error').toLowerCase(),
          message: genericMatch.group(5)!,
        ));
        continue;
      }

      final simpleMatch = simplePattern.firstMatch(trimmed);
      if (simpleMatch != null) {
        issues.add(AnalysisIssue(
          severity: simpleMatch.group(1)!.toLowerCase(),
          message: simpleMatch.group(2)!,
        ));
      }
    }

    if (issues.isEmpty &&
        output.trim().isNotEmpty &&
        output.contains('error')) {
      issues.add(AnalysisIssue(severity: 'error', message: output.trim()));
    }

    return issues;
  }
}
