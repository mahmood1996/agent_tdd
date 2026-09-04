import '../domain/executable_process_result.dart';
import 'processes.dart';

class GitClient {
  final String projectDir;
  final Processes processes;

  GitClient({
    required this.projectDir,
    Processes? processes,
  }) : processes = processes ?? Processes(projectDir);

  Future<bool> isGitRepo() async {
    ExecutableProcessResult? res;
    await processes.process('git rev-parse --is-inside-work-tree').execute(
          onFinished: (result) => res = result,
        );
    return res != null && res!.isSuccess && res!.stdout.trim() == 'true';
  }

  Future<bool> commit(String message) async {
    if (!await isGitRepo()) return false;

    await processes.process('git add .').execute();

    final escapedMsg = message.replaceAll('"', '\\"');
    ExecutableProcessResult? res;
    await processes.process('git commit -m "$escapedMsg"').execute(
          onFinished: (result) => res = result,
        );
    return res != null && res!.isSuccess;
  }
}
