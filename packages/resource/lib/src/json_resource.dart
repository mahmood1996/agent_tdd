import 'dart:convert';
import 'dart:io';

import 'resource.dart';

final class JsonResource implements Resource<dynamic> {
  JsonResource(this._file);

  final File _file;

  @override
  Future<dynamic> content() async {
    await _checkForFileExistence();

    return switch (await _file.readAsString()) {
      '' => '',
      final text => jsonDecode(text),
    };
  }

  Future<void> _checkForFileExistence() async {
    if (await _file.exists()) return;

    throw ResourceNotFoundException('File does not exist: ${_file.path}');
  }

  @override
  Future<void> save(dynamic data) async {
    await _createSaveDirIfNeeded();

    await _file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> _createSaveDirIfNeeded() async {
    if (await _file.parent.exists()) return;

    await _file.parent.create(recursive: true);
  }

  @override
  Future<void> delete() async {
    if (await _file.exists()) await _file.delete();
  }
}
