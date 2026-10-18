import '../data/config_store.dart';

import '../domain/analysis_result.dart';

import 'package:processes/processes.dart';

/// Pure abstract interface for static analysis execution.
abstract interface class Analyzer {
  factory Analyzer({
    required String projectDir,
    ConfigStore? configStore,
    Processes? processes,
  }) = _Analyzer;

  Future<AnalysisResult> analysisResult();
}

/// Private default implementation of [Analyzer].
final class _Analyzer implements Analyzer {
  final String projectDir;
  final ConfigStore configStore;
  final Processes processes;

  _Analyzer({
    required this.projectDir,
    ConfigStore? configStore,
    Processes? processes,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        processes = processes ?? Processes(projectDir);

  @override
  Future<AnalysisResult> analysisResult() async {
    final config = await configStore.config();
    final cmd = config.analyzeCommand;
    if (cmd == null || cmd.isEmpty) {
      return AnalysisResult.clean();
    }

    ExecutableProcessResult? res;

    await processes
        .process(cmd, onFinished: (result) => res = result)
        .execute();

    final result = res!;

    return AnalysisResult(
      result.combinedOutput,
      isSuccess: result.isSuccess,
      failOnWarnings: config.failOnWarnings,
    );
  }
}
