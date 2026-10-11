import '../../../core/data/config_store.dart';
import '../../../core/data/tdd_state_store.dart';
import 'package:tdd_spec_store/tdd_spec_store.dart';
import '../../../core/domain/tdd_config.dart';
import '../../../core/domain/tdd_state.dart';

final class GetStatusResult {
  final TddState state;
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
  final TddSpecStore specStore;
  final TddStateStore stateStore;

  GetStatusUseCase({
    required this.projectDir,
    ConfigStore? configStore,
    TddSpecStore? specStore,
    TddStateStore? stateStore,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? TddSpecStore.file(projectDir),
        stateStore = stateStore ?? TddStateStore(projectDir: projectDir);

  Future<GetStatusResult> execute() async {
    final state = await stateStore.currentState();
    final config = await configStore.config();
    final summary = await specStore.summary();

    return GetStatusResult(
      state: state,
      config: config,
      summary: summary,
    );
  }
}
