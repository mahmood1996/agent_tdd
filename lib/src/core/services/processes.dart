import 'dart:io';

import '../domain/executable_process_result.dart';

final class Processes {
  final String workingDirectory;

  const Processes([this.workingDirectory = '.']);

  ExecutableProcess process(String command) =>
      ExecutableProcess(command, workingDirectory: workingDirectory);
}

final class ExecutableProcess {
  final String command;
  final String workingDirectory;

  const ExecutableProcess(this.command, {required this.workingDirectory});

  Future<void> execute({
    void Function(ExecutableProcessResult result)? onFinished,
  }) async {
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
