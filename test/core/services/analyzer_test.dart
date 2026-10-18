import 'package:agent_tdd/agent_tdd.dart';
import 'package:agent_tdd/src/core/domain/analysis_result.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('analyzer_test_');

  group('Analyzer Solitary Unit Tests', () {
    late Analyzer analyzer;

    setUp(() {
      analyzer = Analyzer(projectDir: harness.tempDir.path);
    });

    test('Execute Dart analyze issue format', () async {
      harness.createFile(
        '.tddrc.yaml',
        'analyze_command: "echo \\"  warning • Unused import • lib/foo.dart:12:3\\""',
      );
      final result = await analyzer.analysisResult();
      expect(result.issues.length, equals(1));
      expect(result.issues.first.severity, equals('warning'));
      expect(result.issues.first.file, equals('lib/foo.dart'));
      expect(result.issues.first.line, equals(12));
      expect(result.issues.first.column, equals(3));
      expect(result.issues.first.message, equals('Unused import'));
    });

    test('Execute generic ESLint / Compiler issue format', () async {
      harness.createFile(
        '.tddrc.yaml',
        'analyze_command: "echo \\"src/validator.ts:14:5: error: Unused variable tempBuffer\\""',
      );
      final result = await analyzer.analysisResult();
      expect(result.issues.length, equals(1));
      expect(result.issues.first.file, equals('src/validator.ts'));
      expect(result.issues.first.line, equals(14));
      expect(result.issues.first.column, equals(5));
      expect(result.issues.first.severity, equals('error'));
    });

    test('Returns clean result when analyze_command is empty or null',
        () async {
      final result = await analyzer.analysisResult();
      expect(result.isClean, isTrue);
      expect(result.issues, isEmpty);
    });
  });

  group('AnalysisIssue Dispatch Table Unit Tests', () {
    test('parses Dart analyze format correctly', () {
      final issue =
          AnalysisIssue('  info • TODO: refactor • lib/src/app.dart:10:4');
      expect(issue.severity, equals('info'));
      expect(issue.file, equals('lib/src/app.dart'));
      expect(issue.line, equals(10));
      expect(issue.column, equals(4));
      expect(issue.message, equals('TODO: refactor'));
      expect(
          issue.toJson(),
          equals({
            'severity': 'info',
            'file': 'lib/src/app.dart',
            'line': 10,
            'column': 4,
            'message': 'TODO: refactor',
          }));
    });

    test('parses generic compiler format correctly', () {
      final issue = AnalysisIssue('pkg/index.ts:5:2: warning: Deprecated API');
      expect(issue.severity, equals('warning'));
      expect(issue.file, equals('pkg/index.ts'));
      expect(issue.line, equals(5));
      expect(issue.column, equals(2));
      expect(issue.message, equals('Deprecated API'));
    });

    test('parses simple error/warning format correctly', () {
      final issue = AnalysisIssue('error: build failed completely');
      expect(issue.severity, equals('error'));
      expect(issue.file, isNull);
      expect(issue.line, isNull);
      expect(issue.column, isNull);
      expect(issue.message, equals('build failed completely'));
    });

    test('falls back to simple issue when no pattern matches', () {
      final issue = AnalysisIssue('Fatal: unexpected termination');
      expect(issue.severity, equals('error'));
      expect(issue.file, isNull);
      expect(issue.line, isNull);
      expect(issue.column, isNull);
      expect(issue.message, equals('Fatal: unexpected termination'));
    });
  });

  group('AnalysisResult Unit Tests', () {
    test('clean result factory has isClean true and empty issues', () {
      final result = AnalysisResult.clean();
      expect(result.isClean, isTrue);
      expect(result.issues, isEmpty);
    });

    test('empty string returns clean result', () {
      final result = AnalysisResult('   \n  ');
      expect(result.isClean, isTrue);
      expect(result.issues, isEmpty);
    });

    test('parses multiple issue lines filtering out non-matching noise', () {
      const output = '''
Compiling project...
info • Unused import • lib/foo.dart:1:2
Building assets...
src/bar.ts:10:5: error: Type mismatch
Finished compilation.
''';
      final result = AnalysisResult(output, isSuccess: true);
      expect(result.isClean, isFalse);
      expect(result.issues.length, equals(2));
      expect(result.issues[0].file, equals('lib/foo.dart'));
      expect(result.issues[1].file, equals('src/bar.ts'));
    });

    test('respects failOnWarnings setting', () {
      const output = 'warning • Unused import • lib/foo.dart:1:2';
      final lenient =
          AnalysisResult(output, isSuccess: true, failOnWarnings: false);
      expect(lenient.isClean, isTrue);

      final strict =
          AnalysisResult(output, isSuccess: true, failOnWarnings: true);
      expect(strict.isClean, isFalse);
    });

    test(
        'handles unformatted error when process fails or output contains error',
        () {
      const output = 'Process crashed with segmentation fault (error 139)';
      final result = AnalysisResult(output, isSuccess: false);
      expect(result.isClean, isFalse);
      expect(result.issues.length, equals(1));
      expect(result.issues.first.message, equals(output));
    });
  });
}
