import 'package:agent_harness/agent_harness.dart';
import '../../../core/data/config_store.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/tdd_config.dart';

final class GetStatusResult {
  final HarnessState state;
  final TddConfig config;
  final Map<String, dynamic> summary;

  const GetStatusResult({
    required this.state,
    required this.config,
    required this.summary,
  });
}

final class GetStatusUseCase {
  final String projectDir;
  final ConfigStore configStore;
  final SpecStore specStore;
  final StateStore stateStore;

  GetStatusUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    SpecStore? specStore,
    StateStore? stateStore,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        stateStore =
            stateStore ?? FileStateStore(projectDir: projectDir);

  Future<GetStatusResult> execute() async {
    final state = await stateStore.harnessState();
    final config = await configStore.config();
    final summary = await specStore.summary();

    return GetStatusResult(
      state: state,
      config: config,
      summary: summary,
    );
  }
}
