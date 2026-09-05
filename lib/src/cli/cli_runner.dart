import 'package:agent_harness/agent_harness.dart';
import '../core/data/config_store.dart';
import '../core/data/snapshot_store.dart';
import '../core/data/spec_store.dart';
import '../core/services/analyzer.dart';
import '../core/services/git_client.dart';
import '../core/services/test_run_verifications.dart';
import 'commands/init_command.dart';
import 'commands/lifecycle_commands.dart';
import 'commands/specs_command.dart';
import 'commands/verification_commands.dart';

final class CliRunner {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;
  final SnapshotStore snapshotStore;
  final TestRunVerifications testRunVerifications;
  final Analyzer analyzer;
  final GitClient gitClient;
  final HarnessOutput output;

  final InitCommand _initCommand;
  final SpecsCommand _specsCommand;
  final VerificationCommands _verificationCommands;
  final LifecycleCommands _lifecycleCommands;

  CliRunner({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    StateStore? stateStore,
    SnapshotStore? snapshotStore,
    TestRunVerifications? testRunVerifications,
    Analyzer? analyzer,
    GitClient? gitClient,
    HarnessOutput output = const ConsoleOutput(isJsonMode: true),
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir),
        snapshotStore = snapshotStore ?? SnapshotStore(projectDir: projectDir),
        testRunVerifications = testRunVerifications ??
            TestRunVerifications(projectDir, configStore: configStore),
        analyzer = analyzer ??
            Analyzer(projectDir: projectDir, configStore: configStore),
        gitClient = gitClient ?? GitClient(projectDir: projectDir),
        output = output,
        _initCommand = InitCommand(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          output: output,
        ),
        _specsCommand = SpecsCommand(
          projectDir: projectDir,
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          stateStore:
              stateStore ?? FileStateStore(projectDir: projectDir),
          output: output,
        ),
        _verificationCommands = VerificationCommands(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          stateStore:
              stateStore ?? FileStateStore(projectDir: projectDir),
          snapshotStore: snapshotStore ?? SnapshotStore(projectDir: projectDir),
          testRunVerifications: testRunVerifications ??
              TestRunVerifications(projectDir, configStore: configStore),
          analyzer: analyzer ??
              Analyzer(projectDir: projectDir, configStore: configStore),
          gitClient: gitClient ?? GitClient(projectDir: projectDir),
          output: output,
        ),
        _lifecycleCommands = LifecycleCommands(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          stateStore:
              stateStore ?? FileStateStore(projectDir: projectDir),
          snapshotStore: snapshotStore ?? SnapshotStore(projectDir: projectDir),
          gitClient: gitClient ?? GitClient(projectDir: projectDir),
          output: output,
        );

  /// Executes the specified CLI [command] with any accompanying [restArgs].
  ///
  /// This is the sole public entry point for [CliRunner].
  Future<void> runCommand(
    String command, [
    List<String> restArgs = const [],
  ]) async {
    switch (command.toLowerCase()) {
      case 'init':
        final preset = restArgs.isNotEmpty
            ? restArgs.first.replaceAll('--runner=', '')
            : null;
        await _initCommand.execute(runnerPreset: preset);
        break;

      case 'specs':
        await _specsCommand.execute(restArgs);
        break;

      case 'next':
        await _lifecycleCommands.next();
        break;

      case 'verify-red':
      case 'red':
        await _verificationCommands.verifyRed();
        break;

      case 'verify-green':
      case 'green':
        await _verificationCommands.verifyGreen();
        break;

      case 'verify-refactor':
      case 'refactor':
        await _verificationCommands.verifyRefactor();
        break;

      case 'complete':
      case 'done':
        await _lifecycleCommands.complete();
        break;

      case 'status':
        await _lifecycleCommands.status();
        break;

      case 'reset':
        await _lifecycleCommands.reset();
        break;

      default:
        final state = await stateStore.harnessState();
        output.reportFailure(
          error: 'Unknown command "$command". Run "agent-tdd --help" for available commands.',
          state: state,
        );
        break;
    }
  }
}
