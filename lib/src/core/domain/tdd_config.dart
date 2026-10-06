abstract interface class TddConfig {
  static const String configFileName = '.tddrc.yaml';

  static TddConfig? fromPreset(
    String preset,
  ) =>
      switch (preset) {
        'go' => const TddConfig.go(),
        'dart' => const TddConfig.dart(),
        'jest' => const TddConfig.jest(),
        'cargo' => const TddConfig.cargo(),
        'pytest' => const TddConfig.pytest(),
        'vitest' => const TddConfig.vitest(),
        'flutter' => const TddConfig.flutter(),
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
      : this._(
          const {
            'runner': 'dart',
            'testCommand': 'dart test',
            'analyzeCommand': 'dart analyze',
            'testFiles': 'test/**/*_test.dart',
            'sourceFiles': 'lib/**/*.dart',
          },
        );

  const _TddConfigImpl.flutter()
      : this._(
          const {
            'runner': 'flutter',
            'testCommand': 'flutter test',
            'analyzeCommand': 'flutter analyze',
            'testFiles': 'test/**/*_test.dart',
            'sourceFiles': 'lib/**/*.dart',
          },
        );

  const _TddConfigImpl.vitest()
      : this._(
          const {
            'runner': 'vitest',
            'testCommand': 'npx vitest run',
            'analyzeCommand': 'npx eslint . --max-warnings 0',
            'testFiles': 'src/**/*.test.ts',
            'sourceFiles': 'src/**/*.ts',
          },
        );

  const _TddConfigImpl.jest()
      : this._(
          const {
            'runner': 'jest',
            'testCommand': 'npx jest',
            'analyzeCommand': 'npx eslint . --max-warnings 0',
            'testFiles': 'src/**/*.test.js',
            'sourceFiles': 'src/**/*.js',
          },
        );

  const _TddConfigImpl.pytest()
      : this._(const {
          'runner': 'pytest',
          'testCommand': 'pytest',
          'analyzeCommand': 'flake8',
          'testFiles': 'tests/**/test_*.py',
          'sourceFiles': 'src/**/*.py',
        });

  const _TddConfigImpl.go()
      : this._(
          const {
            'runner': 'go',
            'testCommand': 'go test ./...',
            'analyzeCommand': 'go vet ./...',
            'testFiles': '**/*_test.go',
            'sourceFiles': '**/*.go',
          },
        );

  const _TddConfigImpl.cargo()
      : this._(
          const {
            'runner': 'cargo',
            'testCommand': 'cargo test',
            'analyzeCommand': 'cargo check',
            'testFiles': 'tests/**/*.rs',
            'sourceFiles': 'src/**/*.rs',
          },
        );

  const _TddConfigImpl._(this._props);

  final Map<String, dynamic> _props;

  @override
  String get runner => _props['runner'];

  @override
  String get testCommand => _props['testCommand'] ?? '';

  @override
  String? get analyzeCommand => _props['analyzeCommand'];

  @override
  String get testFiles => _props['testFiles'] ?? '';

  @override
  String get sourceFiles => _props['sourceFiles'] ?? '';

  @override
  bool get gitCommit => _props['gitCommit'] ?? true;

  @override
  bool get failOnWarnings => _props['failOnWarnings'] ?? true;
}
