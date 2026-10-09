import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';



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

    test('specs retrieves specs saved by addSpec', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');

      await store.addSpec('Spec 1', 'desc 1');
      await store.addSpec('Spec 2', 'desc 2');

      final retrievedSpecs = await store.specs();

      expect(retrievedSpecs.length, equals(2));
      expect(retrievedSpecs[0].id, equals(1));
      expect(retrievedSpecs[0].title, equals('Spec 1'));
      expect(retrievedSpecs[0].status, equals('pending'));
      expect(retrievedSpecs[1].id, equals(2));
      expect(retrievedSpecs[1].title, equals('Spec 2'));
      expect(retrievedSpecs[1].status, equals('pending'));
    });

    test('addSpec writes valid YAML to disk', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      await store.addSpec('Spec 1', 'desc 1');

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

    test('updateSpecStatus updates status correctly', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      await store.addSpec('Spec 1', 'desc 1');

      await store.updateSpecStatus(1, 'done');
      final specs = await store.specs();

      expect(specs.length, equals(1));
      expect(specs[0].status, equals('done'));
    });

    test('FileSpecStore workflow with SmartSpecStore extension', () async {
      final store = FileSpecStore(tempDir.path, 'specs.yaml');
      await store.addSpec('Item 1', 'desc 1');
      await store.addSpec('Item 2', 'desc 2');

      final next = await store.nextPendingSpec();
      expect(next?.id, equals(1));

      await store.markSpecDone(1);

      final nextAfterDone = await store.nextPendingSpec();
      expect(nextAfterDone?.id, equals(2));
    });
  });
}
