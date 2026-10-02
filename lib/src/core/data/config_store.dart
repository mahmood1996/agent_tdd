import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../domain/tdd_config.dart';

final class ConfigStore {
  ConfigStore({required String projectDir}) : _projectDir = projectDir;

  final String _projectDir;

  /// Fetches the project's configuration (loads from .tddrc.yaml if present, or auto-detects).
  Future<TddConfig> config() async {
    final configFile = _configFile;

    return (await configFile.exists())
        ? await _savedConfigFrom(configFile.path)
        : await TddConfig.detectedOn(_projectDir);
  }

  Future<TddConfig> _savedConfigFrom(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Configuration file not found: $filePath');
    }
    final content = await file.readAsString();
    final doc = loadYaml(content);
    if (doc is! Map) {
      throw Exception('Invalid YAML configuration format in $filePath');
    }

    final String runner = doc['runner']?.toString() ?? 'custom';
    final preset = TddConfig.presets[runner];

    return TddConfig(
      runner: runner,
      testCommand:
          doc['test_command']?.toString() ?? preset?.testCommand ?? 'dart test',
      analyzeCommand:
          doc['analyze_command']?.toString() ?? preset?.analyzeCommand,
      testFiles: doc['test_files']?.toString() ??
          preset?.testFiles ??
          'test/**/*_test.dart',
      sourceFiles: doc['source_files']?.toString() ??
          preset?.sourceFiles ??
          'lib/**/*.dart',
      failOnWarnings: doc['fail_on_warnings'] as bool? ?? true,
      gitCommit: doc['git_commit'] as bool? ?? true,
    );
  }

  Future<void> save(TddConfig config) async {
    final yamlContent = StringBuffer()
      ..writeln('# agent-tdd Configuration')
      ..writeln('runner: "${config.runner}"')
      ..writeln('test_command: "${config.testCommand}"')
      ..writeln('analyze_command: "${config.analyzeCommand ?? ''}"')
      ..writeln('test_files: "${config.testFiles}"')
      ..writeln('source_files: "${config.sourceFiles}"')
      ..writeln('fail_on_warnings: ${config.failOnWarnings}')
      ..writeln('git_commit: ${config.gitCommit}');

    await _configFile.writeAsString(yamlContent.toString());
  }

  File get _configFile => File(p.join(_projectDir, TddConfig.configFileName));
}
