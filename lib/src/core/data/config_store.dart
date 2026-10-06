import 'package:path/path.dart' as p;

import 'package:config/config.dart';

import '../domain/tdd_config.dart';

abstract interface class ConfigStore {
  factory ConfigStore({required String projectDir}) = _ConfigStoreImpl;

  Future<TddConfig> config();

  Future<void> save(TddConfig config);
}

final class _ConfigStoreImpl implements ConfigStore {
  _ConfigStoreImpl({
    required String projectDir,
  }) : _fileStore =
            FileConfigStore(p.join(projectDir, TddConfig.configFileName));

  final FileConfigStore _fileStore;

  @override
  Future<TddConfig> config() async => _TddConfig(await _fileStore.config());

  @override
  Future<void> save(TddConfig config) async =>
      await _fileStore.save(_SerializedTddConfig(config));
}

/// Private class implementing [TddConfig] by wrapping a [ReadableConfig]
final class _TddConfig implements TddConfig {
  const _TddConfig(this._readable);

  final ReadableConfig _readable;

  @override
  String get testCommand =>
      _readable.valueBy<String>('test_command', _preset?.testCommand ?? '');

  @override
  String? get analyzeCommand =>
      _readable.valueBy<String?>('analyze_command', _preset?.analyzeCommand);

  @override
  String get testFiles =>
      _readable.valueBy<String>('test_files', _preset?.testFiles ?? '');

  @override
  String get sourceFiles =>
      _readable.valueBy<String>('source_files', _preset?.sourceFiles ?? '');

  TddConfig? get _preset => TddConfig.fromPreset(runner);

  @override
  String get runner => _readable.valueBy<String>('runner', '');

  @override
  bool get failOnWarnings => _readable.valueBy<bool>('fail_on_warnings', true);

  @override
  bool get gitCommit => _readable.valueBy<bool>('git_commit', true);
}

/// Private class implementing [SerializableConfig] by wrapping a [TddConfig]
final class _SerializedTddConfig implements SerializableConfig {
  const _SerializedTddConfig(this._config);

  final TddConfig _config;

  @override
  Map<String, dynamic> toMap() => {
        'runner': _config.runner,
        'test_command': _config.testCommand,
        'analyze_command': _config.analyzeCommand,
        'test_files': _config.testFiles,
        'source_files': _config.sourceFiles,
        'fail_on_warnings': _config.failOnWarnings,
        'git_commit': _config.gitCommit,
      };
}
