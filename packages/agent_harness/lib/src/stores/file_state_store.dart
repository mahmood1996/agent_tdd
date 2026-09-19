import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/harness_state.dart';
import 'state_store.dart';

/// [StateStore] implementation that persists [HarnessState] to JSON files on disk.
final class FileStateStore implements StateStore {
  final String saveDir;
  final String filePath;

  FileStateStore(this.saveDir, this.filePath);

  @override
  Future<HarnessState> savedState() async {
    try {
      return await _tryGettingSavedState();
    } on FileSystemException {
      return _HarnessState.fromJson({});
    }
  }

  Future<_HarnessState> _tryGettingSavedState() async {
    if (!await _file.exists()) return _HarnessState.fromJson({});
    final content = await _file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return _HarnessState.fromJson(json);
  }

  @override
  Future<void> saveState(HarnessState state) async {
    await _createSaveDirIfNeeded(_file);

    final harnessState = _HarnessState(state);

    final jsonString = const JsonEncoder.withIndent('  ').convert(
      harnessState.toJson(),
    );

    await _file.writeAsString(jsonString);
  }

  Future<void> _createSaveDirIfNeeded(File file) async {
    if (await file.parent.exists()) return;

    await file.parent.create(recursive: true);
  }

  File get _file => File(p.join(saveDir, filePath));
}

/// Internal implementation of [HarnessState] for JSON serialization.
final class _HarnessState implements HarnessState {
  /// Constructs [_HarnessState] from a [HarnessState] instance.
  _HarnessState(HarnessState state)
      : this._({
          'phase': state.phase,
          'extra': state.extra,
          'nextCommand': state.nextCommand,
          'editablePatterns': state.editablePatterns,
          'readOnlyPatterns': state.readOnlyPatterns,
        });

  /// Constructs [_HarnessState] from JSON data.
  factory _HarnessState.fromJson(Map<String, dynamic> json) => _HarnessState._({
        'phase': json['phase'],
        'extra': json['extra'],
        'nextCommand': json['next_command'],
        'editablePatterns': json['editable_patterns'],
        'readOnlyPatterns': json['read_only_patterns'],
      });

  _HarnessState._(this._props);

  final Map<String, dynamic> _props;

  @override
  String get phase => _props['phase']?.toString() ?? '';

  @override
  String? get nextCommand => _props['nextCommand']?.toString();

  @override
  Map<String, dynamic> get extra =>
      Map<String, dynamic>.unmodifiable(_props['extra'] ?? {});

  @override
  List<String> get editablePatterns =>
      List<String>.unmodifiable(_props['editablePatterns'] ?? []);

  @override
  List<String> get readOnlyPatterns =>
      List<String>.unmodifiable(_props['readOnlyPatterns'] ?? []);

  /// Converts state to a JSON map representation.
  Map<String, dynamic> toJson() {
    return {
      'phase': _props['phase'],
      'extra': _props['extra'],
      if (_props['nextCommand'] != null) 'next_command': _props['nextCommand'],
      'editable_patterns': _props['editablePatterns'],
      'read_only_patterns': _props['readOnlyPatterns'],
    };
  }
}
