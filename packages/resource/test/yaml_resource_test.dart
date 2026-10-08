import 'dart:io';

import 'package:resource/resource.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('YamlResource', () {
    late Directory tempDir;
    late File storeFile;
    late YamlResource store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('yaml_resource_test_');
      storeFile = File(p.join(tempDir.path, 'state.yaml'));
      store = YamlResource(storeFile);
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

    test('save() creates file and writes yaml', () async {
      final data = {'hello': 'world', 'count': 1};
      await store.save(data);

      expect(await storeFile.exists(), isTrue);

      final savedContent = await storeFile.readAsString();
      expect(savedContent, contains('hello: "world"'));
      expect(savedContent, contains('count: 1'));
    });

    test('content() reads saved yaml', () async {
      final data = {'phase': 'red', 'updated': true};
      await store.save(data);

      final readData = await store.content();
      expect(readData['phase'], equals('red'));
      expect(readData['updated'], equals(true));
    });

    test('delete() removes the file', () async {
      await store.save({'key': 'value'});
      expect(await storeFile.exists(), isTrue);

      await store.delete();
      expect(await storeFile.exists(), isFalse);
    });
  });
}
