abstract interface class TddConfig {
  String get runner;

  bool get gitCommit;

  String get testFiles;

  String get testCommand;

  String get sourceFiles;

  bool get failOnWarnings;

  String? get analyzeCommand;

  static const String configFileName = '.tddrc.yaml';

  static const Map<String, TddConfig> presets = {
    'dart': const _TddConfigImpl(
      runner: 'dart',
      testCommand: 'dart test',
      analyzeCommand: 'dart analyze',
      testFiles: 'test/**/*_test.dart',
      sourceFiles: 'lib/**/*.dart',
    ),
    'flutter': const _TddConfigImpl(
      runner: 'flutter',
      testCommand: 'flutter test',
      analyzeCommand: 'flutter analyze',
      testFiles: 'test/**/*_test.dart',
      sourceFiles: 'lib/**/*.dart',
    ),
    'vitest': const _TddConfigImpl(
      runner: 'vitest',
      testCommand: 'npx vitest run',
      analyzeCommand: 'npx eslint . --max-warnings 0',
      testFiles: 'src/**/*.test.ts',
      sourceFiles: 'src/**/*.ts',
    ),
    'jest': const _TddConfigImpl(
      runner: 'jest',
      testCommand: 'npx jest',
      analyzeCommand: 'npx eslint . --max-warnings 0',
      testFiles: 'src/**/*.test.js',
      sourceFiles: 'src/**/*.js',
    ),
    'pytest': const _TddConfigImpl(
      runner: 'pytest',
      testCommand: 'pytest',
      analyzeCommand: 'flake8',
      testFiles: 'tests/**/test_*.py',
      sourceFiles: 'src/**/*.py',
    ),
    'go': const _TddConfigImpl(
      runner: 'go',
      testCommand: 'go test ./...',
      analyzeCommand: 'go vet ./...',
      testFiles: '**/*_test.go',
      sourceFiles: '**/*.go',
    ),
    'cargo': const _TddConfigImpl(
      runner: 'cargo',
      testCommand: 'cargo test',
      analyzeCommand: 'cargo check',
      testFiles: 'tests/**/*.rs',
      sourceFiles: 'src/**/*.rs',
    ),
  };
}

final class _TddConfigImpl implements TddConfig {
  const _TddConfigImpl({
    required this.runner,
    required this.testCommand,
    this.analyzeCommand,
    required this.testFiles,
    required this.sourceFiles,
  });

  @override
  final String runner;

  @override
  final String testCommand;

  @override
  final String? analyzeCommand;

  @override
  final String testFiles;

  @override
  final String sourceFiles;

  @override
  bool get gitCommit => true;

  @override
  bool get failOnWarnings => true;
}
