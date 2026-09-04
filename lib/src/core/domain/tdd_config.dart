final class TddConfig {
  final String runner;
  final String testCommand;
  final String? analyzeCommand;
  final String testFiles;
  final String sourceFiles;
  final bool failOnWarnings;
  final bool gitCommit;

  const TddConfig({
    required this.runner,
    required this.testCommand,
    this.analyzeCommand,
    required this.testFiles,
    required this.sourceFiles,
    this.failOnWarnings = true,
    this.gitCommit = true,
  });

  TddConfig copyWith({
    String? runner,
    String? testCommand,
    String? analyzeCommand,
    String? testFiles,
    String? sourceFiles,
    bool? failOnWarnings,
    bool? gitCommit,
  }) {
    return TddConfig(
      runner: runner ?? this.runner,
      testCommand: testCommand ?? this.testCommand,
      analyzeCommand: analyzeCommand ?? this.analyzeCommand,
      testFiles: testFiles ?? this.testFiles,
      sourceFiles: sourceFiles ?? this.sourceFiles,
      failOnWarnings: failOnWarnings ?? this.failOnWarnings,
      gitCommit: gitCommit ?? this.gitCommit,
    );
  }

  static const String configFileName = '.tddrc.yaml';

  static final Map<String, TddConfig> presets = {
    'dart': const TddConfig(
      runner: 'dart',
      testCommand: 'dart test',
      analyzeCommand: 'dart analyze',
      testFiles: 'test/**/*_test.dart',
      sourceFiles: 'lib/**/*.dart',
    ),
    'flutter': const TddConfig(
      runner: 'flutter',
      testCommand: 'flutter test',
      analyzeCommand: 'flutter analyze',
      testFiles: 'test/**/*_test.dart',
      sourceFiles: 'lib/**/*.dart',
    ),
    'vitest': const TddConfig(
      runner: 'vitest',
      testCommand: 'npx vitest run',
      analyzeCommand: 'npx eslint . --max-warnings 0',
      testFiles: 'src/**/*.test.ts',
      sourceFiles: 'src/**/*.ts',
    ),
    'jest': const TddConfig(
      runner: 'jest',
      testCommand: 'npx jest',
      analyzeCommand: 'npx eslint . --max-warnings 0',
      testFiles: 'src/**/*.test.js',
      sourceFiles: 'src/**/*.js',
    ),
    'pytest': const TddConfig(
      runner: 'pytest',
      testCommand: 'pytest',
      analyzeCommand: 'flake8',
      testFiles: 'tests/**/test_*.py',
      sourceFiles: 'src/**/*.py',
    ),
    'go': const TddConfig(
      runner: 'go',
      testCommand: 'go test ./...',
      analyzeCommand: 'go vet ./...',
      testFiles: '**/*_test.go',
      sourceFiles: '**/*.go',
    ),
    'cargo': const TddConfig(
      runner: 'cargo',
      testCommand: 'cargo test',
      analyzeCommand: 'cargo check',
      testFiles: 'tests/**/*.rs',
      sourceFiles: 'src/**/*.rs',
    ),
  };

  Map<String, dynamic> toJson() {
    return {
      'runner': runner,
      'test_command': testCommand,
      'analyze_command': analyzeCommand,
      'test_files': testFiles,
      'source_files': sourceFiles,
      'fail_on_warnings': failOnWarnings,
      'git_commit': gitCommit,
    };
  }
}
