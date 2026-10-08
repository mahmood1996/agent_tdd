import 'dart:convert';
import 'dart:io';

import 'package:resource/resource.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('JsonResource', () {
    late Directory tempDir;
    late File storeFile;
    late JsonResource store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('json_resource_test_');
      storeFile = File(p.join(tempDir.path, 'state.json'));
      store = JsonResource(storeFile);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'content() throws ResourceNotFoundException when file does not exist',
      () async {
        expect(
          () => store.content(),
          throwsA(isA<ResourceNotFoundException>()),
        );
      },
    );

    test('save() creates file and writes json', () async {
      final data = {'hello': 'world', 'count': 1};
      await store.save(data);

      expect(await storeFile.exists(), isTrue);

      final savedContent = await storeFile.readAsString();
      final decoded = jsonDecode(savedContent);
      expect(decoded, equals(data));
    });

    test('content() reads saved json', () async {
      final data = {'phase': 'red', 'updated': true};
      await store.save(data);

      final readData = await store.content();
      expect(readData, equals(data));
    });

    test('delete() removes the file', () async {
      await store.save({'key': 'value'});
      expect(await storeFile.exists(), isTrue);

      await store.delete();
      expect(await storeFile.exists(), isFalse);
    });

    test('delete() does not throw if file already does not exist', () async {
      expect(await storeFile.exists(), isFalse);

      // Should complete normally
      await expectLater(store.delete(), completes);
    });
  });
}
