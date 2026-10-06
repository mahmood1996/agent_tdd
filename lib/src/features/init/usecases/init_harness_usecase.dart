import '../../../core/data/config_store.dart';
import '../../../core/services/config_detection.dart';
import '../../../core/data/spec_store.dart';
import '../../../core/domain/tdd_config.dart';

final class InitHarnessResult {
  final bool success;
  final TddConfig config;
  final bool specCreated;
  final String message;

  const InitHarnessResult({
    required this.success,
    required this.config,
    required this.specCreated,
    required this.message,
  });
}

final class InitHarnessUseCase {
  final String projectDir;

  final SpecStore specStore;

  final ConfigStore configStore;

  final ConfigDetection configDetection;

  InitHarnessUseCase({
    required this.projectDir,
    SpecStore? specStore,
    ConfigStore? configStore,
    ConfigDetection? configDetection,
  })  : configStore = configStore ?? ConfigStore(projectDir: projectDir),
        specStore = specStore ?? SpecStore(projectDir: projectDir),
        configDetection = configDetection ?? ConfigDetection();

  Future<InitHarnessResult> execute({String? runnerPreset}) async {
    final config = TddConfig.fromPreset(runnerPreset ?? '') ??
        await configDetection.detectedConfig(projectDir);

    await configStore.save(config);

    bool specCreated = false;
    final currentSpecs = await specStore.specs();
    if (currentSpecs.isEmpty) {
      await specStore.addSpec('Sample Feature Spec - Replace with your own');
      specCreated = true;
    }

    return InitHarnessResult(
      success: true,
      config: config,
      specCreated: specCreated,
      message: 'Initialized agent-tdd in $projectDir!',
    );
  }
}
