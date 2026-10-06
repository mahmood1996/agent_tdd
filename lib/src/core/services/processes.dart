import 'dart:io';

import '../domain/executable_process_result.dart';

final class Processes {
  final String workingDirectory;

  const Processes([this.workingDirectory = '.']);

  ExecutableProcess process(
    String command, {
    void Function(ExecutableProcessResult result)? onFinished,
  }) =>
      ExecutableProcess(
        command,
        onFinished: onFinished,
        workingDirectory: workingDirectory,
      );
}

final class ExecutableProcess {
  final String command;
  final String workingDirectory;

  final void Function(ExecutableProcessResult result)? onFinished;

  const ExecutableProcess(
    this.command, {
    required this.workingDirectory,
    this.onFinished,
  });

  Future<void> execute() async {
    final sw = Stopwatch()..start();

    final res = Platform.isWindows
        ? await Process.run('cmd.exe', ['/c', command],
            workingDirectory: workingDirectory)
        : await Process.run('sh', ['-c', command],
            workingDirectory: workingDirectory);

    sw.stop();

    onFinished?.call(ExecutableProcessResult(
      exitCode: res.exitCode,
      stdout: res.stdout.toString(),
      stderr: res.stderr.toString(),
      durationMs: sw.elapsedMilliseconds,
    ));
  }
}
