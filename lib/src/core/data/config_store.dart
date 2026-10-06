import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:config/config.dart';

import '../domain/tdd_config.dart';
import '../services/config_detection.dart';

abstract interface class ConfigStore {
  factory ConfigStore({required String projectDir}) = _ConfigStoreImpl;

  Future<TddConfig> config();

  Future<void> save(TddConfig config);
}

final class _ConfigStoreImpl implements ConfigStore {
  _ConfigStoreImpl({
    required String projectDir,
    ConfigDetection? detection,
  })  : _projectDir = projectDir,
        _fileStore =
            FileConfigStore(p.join(projectDir, TddConfig.configFileName)),
        _detection = detection ?? ConfigDetection();

  final String _projectDir;
  final FileConfigStore _fileStore;
  final ConfigDetection _detection;

  @override
  Future<TddConfig> config() async =>
      await File(p.join(_projectDir, TddConfig.configFileName)).exists()
          ? _TddConfig(await _fileStore.config())
          : (await _detection.detectConfig(_projectDir))!;

  @override
  Future<void> save(TddConfig config) async =>
      await _fileStore.save(_SerializedTddConfig(config));
}

/// Private class implementing [TddConfig] by wrapping a [ReadableConfig]
final class _TddConfig implements TddConfig {
  const _TddConfig(this._readable);

  final ReadableConfig _readable;

  @override
  String get runner => _readable.valueBy<String>('runner', 'custom');

  TddConfig? get _preset => TddConfig.presets[runner];

  @override
  String get testCommand => _readable.valueBy<String>(
      'test_command', _preset?.testCommand ?? 'dart test');

  @override
  String? get analyzeCommand =>
      _readable.valueBy<String?>('analyze_command', _preset?.analyzeCommand);

  @override
  String get testFiles => _readable.valueBy<String>(
      'test_files', _preset?.testFiles ?? 'test/**/*_test.dart');

  @override
  String get sourceFiles => _readable.valueBy<String>(
      'source_files', _preset?.sourceFiles ?? 'lib/**/*.dart');

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
