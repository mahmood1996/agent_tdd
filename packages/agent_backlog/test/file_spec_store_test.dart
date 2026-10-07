import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

import 'fakes/fake_spec.dart';
import 'matchers/spec_matchers.dart';

void main() {
  group('FileSpecStore Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_spec_store_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('specs retrieves specs saved by saveSpecs', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      final originalSpecs = [
        const FakeSpec(
          id: 1,
          title: 'Spec 1',
          description: 'desc 1',
          status: 'pending',
          metadata: {'meta': 'val'},
        ),
        const FakeSpec(
          id: 2,
          title: 'Spec 2',
          description: 'desc 2',
          status: 'done',
        ),
      ];

      await store.saveSpecs(originalSpecs);
      final retrievedSpecs = await store.specs();

      expect(retrievedSpecs.length, equals(2));
      expect(retrievedSpecs[0], equalsSpec(originalSpecs[0]));
      expect(retrievedSpecs[1], equalsSpec(originalSpecs[1]));
    });

    test('saveSpecs writes valid YAML to disk', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      await store.saveSpecs([
        const FakeSpec(
          id: 1,
          title: 'Spec 1',
          description: 'desc 1',
          status: 'pending',
          metadata: {},
        ),
      ]);

      final file = File('${tempDir.path}/specs.yaml');
      final content = await file.readAsString();

      // YAML list entries start with "- "
      expect(content, contains('- '));
      // File must not start with JSON array syntax
      expect(content.trimLeft(), isNot(startsWith('[')));
      expect(content, contains('id:'));
      expect(content, contains('title:'));
      expect(content, contains('status:'));
    });

    test('specs returns empty list if file does not exist', () async {
      final store = FileSpecStore(tempDir.path, 'non_existent.yaml');
      final specs = await store.specs();
      expect(specs, isEmpty);
    });

    test('FileSpecStore workflow with SmartSpecStore extension', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      await store.saveSpecs([
        const FakeSpec(
            id: 1, title: 'Item 1', description: 'desc 1', status: 'pending'),
        const FakeSpec(
            id: 2, title: 'Item 2', description: 'desc 2', status: 'pending'),
      ]);

      final next = await store.nextPendingSpec();
      expect(next?.id, equals(1));

      await store.markSpecDone(1);

      final nextAfterDone = await store.nextPendingSpec();
      expect(nextAfterDone?.id, equals(2));
    });
  });
}
