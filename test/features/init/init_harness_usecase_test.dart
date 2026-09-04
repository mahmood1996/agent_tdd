import 'dart:io';

import 'package:agent_tdd/agent_tdd.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('init_usecase_test_');

  group('InitHarnessUseCase Solitary Unit Tests', () {
    test('Initializes configuration and sample spec', () async {
      harness.createFile('pubspec.yaml', 'name: test_app\n');

      final useCase = InitHarnessUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute(runnerPreset: 'dart');

      expect(res.success, isTrue);
      expect(res.config.runner, equals('dart'));
      expect(res.specCreated, isTrue);
      expect(
        File(p.join(harness.tempDir.path, TddConfig.configFileName)).existsSync(),
        isTrue,
      );
    });
  });
}
