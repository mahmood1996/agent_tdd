import 'package:agent_tdd/agent_tdd.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('add_spec_usecase_test_');

  group('AddSpecUseCase Behavioral Solitary Unit Tests', () {
    test('execute adds spec item with title and description', () async {
      final useCase = AddSpecUseCase(projectDir: harness.tempDir.path);
      final res = await useCase.execute('User Authentication', description: 'Implement JWT login');

      expect(res.newSpec.id, equals(1));
      expect(res.newSpec.title, equals('User Authentication'));
      expect(res.newSpec.description, equals('Implement JWT login'));
      expect(res.newSpec.status, equals('pending'));
      expect(res.currentState.isIdle, isTrue);
    });

    test('execute increments ID for multiple specs', () async {
      final useCase = AddSpecUseCase(projectDir: harness.tempDir.path);
      final res1 = await useCase.execute('Spec 1');
      final res2 = await useCase.execute('Spec 2');

      expect(res1.newSpec.id, equals(1));
      expect(res2.newSpec.id, equals(2));
    });
  });
}
