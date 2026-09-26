import '../core/data/config_store.dart';
import '../core/data/spec_store.dart';
import '../core/data/tdd_cycle.dart';
import '../core/services/analyzer.dart';
import '../core/services/git_client.dart';
import '../core/services/test_run_verifications.dart';
import 'commands/init_command.dart';
import 'commands/lifecycle_commands.dart';
import 'commands/specs_command.dart';
import 'commands/verification_commands.dart';
import 'presenter/fallback_presenter.dart';
import 'presenter/init_presenter.dart';
import 'presenter/lifecycle_presenter.dart';
import 'presenter/specs_presenter.dart';
import 'presenter/verification_presenter.dart';

final class CliRunner {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final TddCycle tddCycle;
  final TestRunVerifications testRunVerifications;
  final Analyzer analyzer;
  final GitClient gitClient;

  final InitCommand _initCommand;
  final SpecsCommand _specsCommand;
  final VerificationCommands _verificationCommands;
  final LifecycleCommands _lifecycleCommands;
  final FallbackPresenter _fallbackPresenter;

  CliRunner({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    TddCycle? tddCycle,
    TestRunVerifications? testRunVerifications,
    Analyzer? analyzer,
    GitClient? gitClient,
    InitPresenter initPresenter = const InitPresenter(),
    SpecsPresenter specsPresenter = const SpecsPresenter(),
    VerificationPresenter verificationPresenter = const VerificationPresenter(),
    LifecyclePresenter lifecyclePresenter = const LifecyclePresenter(),
    FallbackPresenter fallbackPresenter = const FallbackPresenter(),
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        tddCycle = tddCycle ?? TddCycle(projectDir: projectDir),
        testRunVerifications = testRunVerifications ??
            TestRunVerifications(projectDir, configStore: configStore),
        analyzer = analyzer ??
            Analyzer(projectDir: projectDir, configStore: configStore),
        gitClient = gitClient ?? GitClient(projectDir: projectDir),
        _fallbackPresenter = fallbackPresenter,
        _initCommand = InitCommand(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          presenter: initPresenter,
        ),
        _specsCommand = SpecsCommand(
          projectDir: projectDir,
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          tddCycle: tddCycle ?? TddCycle(projectDir: projectDir),
          presenter: specsPresenter,
        ),
        _verificationCommands = VerificationCommands(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          tddCycle: tddCycle ?? TddCycle(projectDir: projectDir),
          testRunVerifications: testRunVerifications ??
              TestRunVerifications(projectDir, configStore: configStore),
          analyzer: analyzer ??
              Analyzer(projectDir: projectDir, configStore: configStore),
          gitClient: gitClient ?? GitClient(projectDir: projectDir),
          presenter: verificationPresenter,
        ),
        _lifecycleCommands = LifecycleCommands(
          projectDir: projectDir,
          configStore: configStore ?? ConfigStore(projectDir: projectDir),
          specStore: specStore ?? SpecStore(projectDir: projectDir),
          tddCycle: tddCycle ?? TddCycle(projectDir: projectDir),
          gitClient: gitClient ?? GitClient(projectDir: projectDir),
          presenter: lifecyclePresenter,
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
        final state = await tddCycle.savedTddState();
        _fallbackPresenter.renderUnknownCommand(
          command,
          state.phase.name.toUpperCase(),
        );
        break;
    }
  }
}
