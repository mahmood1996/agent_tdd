abstract interface class TddConfig {
  static const String configFileName = '.tddrc.yaml';

  static TddConfig? fromPreset(
    String preset,
  ) =>
      switch (preset) {
        'dart' => const TddConfig.dart(),
        'flutter' => const TddConfig.flutter(),
        'vitest' => const TddConfig.vitest(),
        'jest' => const TddConfig.jest(),
        'pytest' => const TddConfig.pytest(),
        'go' => const TddConfig.go(),
        'cargo' => const TddConfig.cargo(),
        _ => null,
      };

  const factory TddConfig.dart() = _TddConfigImpl.dart;

  const factory TddConfig.flutter() = _TddConfigImpl.flutter;

  const factory TddConfig.vitest() = _TddConfigImpl.vitest;

  const factory TddConfig.jest() = _TddConfigImpl.jest;

  const factory TddConfig.pytest() = _TddConfigImpl.pytest;

  const factory TddConfig.go() = _TddConfigImpl.go;

  const factory TddConfig.cargo() = _TddConfigImpl.cargo;

  String get runner;

  bool get gitCommit;

  String get testFiles;

  String get testCommand;

  String get sourceFiles;

  bool get failOnWarnings;

  String? get analyzeCommand;
}

final class _TddConfigImpl implements TddConfig {
  const _TddConfigImpl.dart()
      : runner = 'dart',
        testCommand = 'dart test',
        analyzeCommand = 'dart analyze',
        testFiles = 'test/**/*_test.dart',
        sourceFiles = 'lib/**/*.dart';

  const _TddConfigImpl.flutter()
      : runner = 'flutter',
        testCommand = 'flutter test',
        analyzeCommand = 'flutter analyze',
        testFiles = 'test/**/*_test.dart',
        sourceFiles = 'lib/**/*.dart';

  const _TddConfigImpl.vitest()
      : runner = 'vitest',
        testCommand = 'npx vitest run',
        analyzeCommand = 'npx eslint . --max-warnings 0',
        testFiles = 'src/**/*.test.ts',
        sourceFiles = 'src/**/*.ts';

  const _TddConfigImpl.jest()
      : runner = 'jest',
        testCommand = 'npx jest',
        analyzeCommand = 'npx eslint . --max-warnings 0',
        testFiles = 'src/**/*.test.js',
        sourceFiles = 'src/**/*.js';

  const _TddConfigImpl.pytest()
      : runner = 'pytest',
        testCommand = 'pytest',
        analyzeCommand = 'flake8',
        testFiles = 'tests/**/test_*.py',
        sourceFiles = 'src/**/*.py';

  const _TddConfigImpl.go()
      : runner = 'go',
        testCommand = 'go test ./...',
        analyzeCommand = 'go vet ./...',
        testFiles = '**/*_test.go',
        sourceFiles = '**/*.go';

  const _TddConfigImpl.cargo()
      : runner = 'cargo',
        testCommand = 'cargo test',
        analyzeCommand = 'cargo check',
        testFiles = 'tests/**/*.rs',
        sourceFiles = 'src/**/*.rs';

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
