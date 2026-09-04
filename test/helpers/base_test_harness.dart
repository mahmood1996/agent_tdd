import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Base class providing standard test environment setup, temporary directory lifecycle management,
/// and common helper utilities across unit tests.
class BaseTest {
  late Directory tempDir;

  /// Registers standard [setUp] and [tearDown] callbacks for the current group/file.
  void setUpBase([String prefix = 'agent_tdd_test_']) {
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(prefix);
      onSetUp();
    });

    tearDown(() {
      onTearDown();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
  }

  /// Optional hook for test suites to perform custom setup logic.
  void onSetUp() {}

  /// Optional hook for test suites to perform custom teardown logic.
  void onTearDown() {}

  /// Creates a file relative to [tempDir] with the provided [content].
  File createFile(String relativePath, String content) {
    final file = File(p.join(tempDir.path, relativePath));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  /// Helper utility for capturing JSON stdout output in CLI tests.
  static Future<Map<String, dynamic>> captureJsonOutput(
    Future<void> Function() fn,
  ) async {
    final printLogs = <String>[];
    await runZoned(
      fn,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printLogs.add(line);
        },
      ),
    );
    expect(printLogs, isNotEmpty, reason: 'Expected JSON output in stdout');
    final lastLog = printLogs.last;
    return jsonDecode(lastLog) as Map<String, dynamic>;
  }
}
