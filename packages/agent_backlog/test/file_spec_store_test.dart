import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

void main() {
  group('FileSpecStore Tests', () {
    late Directory tempDir;
    late FileSpecStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_spec_store_test_');
      store = FileSpecStore(tempDir.path, 'specs.yaml');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('specs retrieves specs saved by addSpecs', () async {
      await store.addSpecs(NewSpecs.fromMarkdown(
        '- [ ] Spec 1 | desc 1\n- [ ] Spec 2 | desc 2',
      ));

      final retrievedSpecs = await store.specs();

      expect(retrievedSpecs.length, equals(2));
      expect(retrievedSpecs[0].id, equals(1));
      expect(retrievedSpecs[0].title, equals('Spec 1'));
      expect(retrievedSpecs[0].status, equals('pending'));
      expect(retrievedSpecs[1].id, equals(2));
      expect(retrievedSpecs[1].title, equals('Spec 2'));
      expect(retrievedSpecs[1].status, equals('pending'));
    });

    test('addSpecs writes valid YAML to disk', () async {
      await store.addSpecs(NewSpecs.fromMarkdown('- [ ] Spec 1 | desc 1'));

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
      final emptyStore = FileSpecStore(tempDir.path, 'non_existent.yaml');
      final specs = await emptyStore.specs();
      expect(specs, isEmpty);
    });

    test('addSpecs with empty iterable is a no-op', () async {
      await store.addSpecs(const []);
      final specs = await store.specs();
      expect(specs, isEmpty);
    });

    test('addSpecs assigns sequential IDs in a single batch write', () async {
      await store.addSpecs(NewSpecs.fromMarkdown(
        '- [ ] First task\n- [ ] Second task\n- [ ] Third task',
      ));

      final specs = await store.specs();
      expect(specs.length, equals(3));
      expect(specs[0].id, equals(1));
      expect(specs[1].id, equals(2));
      expect(specs[2].id, equals(3));
    });

    test('addSpecs parses description from markdown line', () async {
      await store.addSpecs(NewSpecs.fromMarkdown(
        '- [ ] My spec | Some description',
      ));

      final spec = (await store.specs()).first;
      expect(spec.title, equals('My spec'));
      expect(spec.description, equals('Some description'));
    });

    test('addSpecs parses metadata key:value pairs from markdown line',
        () async {
      await store.addSpecs(NewSpecs.fromMarkdown(
        '- [ ] My spec | Some description | priority:high tag:unit',
      ));

      final spec = (await store.specs()).first;
      expect(spec.metadata['priority'], equals('high'));
      expect(spec.metadata['tag'], equals('unit'));
    });

    test('addSpecs infers done status from [x] marker', () async {
      await store.addSpecs(NewSpecs.fromMarkdown('- [x] Done task'));

      final spec = (await store.specs()).first;
      expect(spec.status, equals('done'));
      expect(spec.isDone, isTrue);
    });

    test('updateSpecStatus updates status correctly', () async {
      await store.addSpecs(NewSpecs.fromMarkdown('- [ ] Spec 1 | desc 1'));

      await store.updateSpecStatus(1, 'done');
      final specs = await store.specs();

      expect(specs.length, equals(1));
      expect(specs[0].status, equals('done'));
    });

    test('FileSpecStore workflow with SmartSpecStore extension', () async {
      await store.addSpecs(NewSpecs.fromMarkdown(
        '- [ ] Item 1 | desc 1\n- [ ] Item 2 | desc 2',
      ));

      final next = await store.nextPendingSpec();
      expect(next?.id, equals(1));

      await store.markSpecDone(1);

      final nextAfterDone = await store.nextPendingSpec();
      expect(nextAfterDone?.id, equals(2));
    });

    test('non-checklist lines in markdown are silently ignored', () async {
      await store.addSpecs(NewSpecs.fromMarkdown('''
# My Specs

Some intro text.

- [ ] Real spec 1
- This is NOT a checklist item
- [ ] Real spec 2
'''));

      final specs = await store.specs();
      expect(specs.length, equals(2));
      expect(specs[0].title, equals('Real spec 1'));
      expect(specs[1].title, equals('Real spec 2'));
    });

    test('adding a Spec with title and description', () async {
      await store.addSpec(
        'fizzBuzzFor(5) returns "Buzz"',
        'Returning "Buzz" when input is 5',
      );

      final spec = (await store.specs()).first;

      expect(spec.isPending, isTrue);
      expect(spec.title, 'fizzBuzzFor(5) returns "Buzz"');
      expect(spec.description, 'Returning "Buzz" when input is 5');
    });
  });
}
