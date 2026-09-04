import 'package:agent_tdd/agent_tdd.dart';
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
  });
}
