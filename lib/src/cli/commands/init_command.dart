import 'package:agent_harness/agent_harness.dart';
import '../../core/data/config_store.dart';
import '../../core/data/spec_store.dart';
import '../../features/init/usecases/init_harness_usecase.dart';

final class InitCommand implements HarnessCommand {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final HarnessOutput output;

  const InitCommand({
    required this.projectDir,
    required this.configStore,
    required this.specStore,
    this.output = const ConsoleOutput(isJsonMode: true),
  });

  @override
  String get name => 'init';

  @override
  String get description => 'Initializes agent-tdd configuration and spec backlog.';

  @override
  Future<void> execute({String? runnerPreset}) async {
    final useCase = InitHarnessUseCase(
      projectDir: projectDir,
      configStore: configStore,
      specStore: specStore,
    );
    final res = await useCase.execute(runnerPreset: runnerPreset);

    if (!res.success) {
      output.reportFailure(
        error: res.message,
        state: const HarnessState(
          phase: 'IDLE',
          editablePatterns: [],
          readOnlyPatterns: [],
          allowedCommands: ['agent-tdd init'],
        ),
      );
      return;
    }

    final state = const HarnessState(
      phase: 'IDLE',
      editablePatterns: [],
      readOnlyPatterns: [],
      nextCommand: 'agent-tdd next',
      allowedCommands: [
        'agent-tdd next',
        'agent-tdd specs',
        'agent-tdd status',
        'agent-tdd reset',
      ],
    );

    output.reportSuccess(
      message:
          'agent-tdd initialized successfully with preset "${res.config.runner}". Add specs to specs.yaml or specs.md, then run "agent-tdd next".',
      state: state,
    );
  }
}
