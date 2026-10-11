import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';
import 'package:tdd_spec_store/tdd_spec_store.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late TddSpecStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tdd_spec_store_pkg_test_');
    store = TddSpecStore.file(tempDir.path, 'specs.yaml');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('TddSpecStore Tests', () {
    test('activeSpec returns null when no specs have active lifecycle status', () async {
      await store.addSpec('Spec 1');
      await store.addSpec('Spec 2');

      expect(await store.activeSpec(), isNull);
    });

    test('activeSpec returns spec when status is in lifecycle statuses', () async {
      await store.addSpec('Spec 1');
      await store.addSpec('Spec 2');

      for (final activeStatus in ['red', 'green', 'refactor', 'already_passed']) {
        await store.updateSpecStatus(1, activeStatus);
        final active = await store.activeSpec();
        expect(active, isNotNull);
        expect(active?.id, equals(1));
        expect(active?.status, equals(activeStatus));
      }
    });

    test('activeSpec ignores done and pending specs', () async {
      await store.addSpec('Spec 1');
      await store.addSpec('Spec 2');
      await store.updateSpecStatus(1, 'done');

      expect(await store.activeSpec(), isNull);
    });

    test('summary calculates counts, percentage, and active spec', () async {
      await store.addSpec('Spec 1');
      await store.addSpec('Spec 2');
      await store.addSpec('Spec 3');

      await store.updateSpecStatus(1, 'done');
      await store.updateSpecStatus(2, 'red');

      final sum = await store.summary();
      expect(sum['total'], equals(3));
      expect(sum['completed'], equals(1));
      expect(sum['percentage'], equals(33));
      expect(sum['active_spec'], isNotNull);
      expect(sum['active_spec']['id'], equals(2));
      expect(sum['specs'], hasLength(3));
    });
  });
}
