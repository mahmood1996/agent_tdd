import 'dart:io';

import 'package:agent_tdd/agent_tdd.dart';
import 'package:agent_tdd/src/core/services/git_client.dart';
import 'package:test/test.dart';

import '../../helpers/base_test_harness.dart';

void main() {
  final harness = BaseTest()..setUpBase('git_client_test_');

  group('GitClient Behavioral Solitary Unit Tests', () {
    test('isGitRepo returns false when directory is not a git repository', () async {
      final client = GitClient(projectDir: harness.tempDir.path);
      final isRepo = await client.isGitRepo();
      expect(isRepo, isFalse);
    });

    test('commit returns false when not in git repository', () async {
      final client = GitClient(projectDir: harness.tempDir.path);
      final success = await client.commit('Initial commit');
      expect(success, isFalse);
    });

    test('isGitRepo and commit succeed in a valid git repository', () async {
      // Initialize git repo in tempDir
      await Process.run('git', ['init'], workingDirectory: harness.tempDir.path);
      await Process.run('git', ['config', 'user.name', 'Test User'], workingDirectory: harness.tempDir.path);
      await Process.run('git', ['config', 'user.email', 'test@example.com'], workingDirectory: harness.tempDir.path);

      final client = GitClient(projectDir: harness.tempDir.path);
      final isRepo = await client.isGitRepo();
      expect(isRepo, isTrue);

      harness.createFile('test.txt', 'hello');
      final committed = await client.commit('Initial test commit');
      expect(committed, isTrue);
    });
  });
}
