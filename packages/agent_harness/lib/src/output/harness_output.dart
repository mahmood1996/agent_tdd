import 'dart:convert';
import '../state/harness_state.dart';

/// Abstract interface for terminal and machine-readable JSON stdout/stderr reporting
abstract interface class HarnessOutput {
  void info(String message);
  void warning(String message);
  void error(String message);

  void reportSuccess({
    required String message,
    required HarnessState state,
  });

  void reportFailure({
    required String error,
    required HarnessState state,
  });
}

/// Standard console implementation emitting CLI text or structured JSON
final class ConsoleOutput implements HarnessOutput {
  final bool isJsonMode;
  final void Function(String text)? printHandler;

  const ConsoleOutput({
    this.isJsonMode = false,
    this.printHandler,
  });

  void _print(String text) {
    if (printHandler != null) {
      printHandler!(text);
    } else {
      print(text);
    }
  }

  @override
  void info(String message) {
    if (!isJsonMode) _print('ℹ️  $message');
  }

  @override
  void warning(String message) {
    if (!isJsonMode) _print('⚠️  $message');
  }

  @override
  void error(String message) {
    if (!isJsonMode) _print('❌ $message');
  }

  @override
  void reportSuccess({required String message, required HarnessState state}) {
    if (isJsonMode) {
      final jsonOutput = {
        'success': true,
        'phase': state.phase,
        ...state.metadata,
        'allowed_actions': {
          if (state.editablePatterns.isNotEmpty)
            'editable_files': state.editablePatterns,
          if (state.readOnlyPatterns.isNotEmpty)
            'read_only_files': state.readOnlyPatterns,
          if (state.nextCommand != null) 'next_command': state.nextCommand,
          if (state.allowedCommands.isNotEmpty)
            'allowed_commands': state.allowedCommands,
        },
        'instructions_for_agent': message,
      };
      _print(jsonEncode(jsonOutput));
    } else {
      info('[${state.phase}] $message');
    }
  }

  @override
  void reportFailure({required String error, required HarnessState state}) {
    if (isJsonMode) {
      final jsonOutput = {
        'success': false,
        'phase': state.phase,
        if (state.metadata.containsKey('active_spec'))
          'active_spec': state.metadata['active_spec'],
        if (state.metadata.containsKey('progress'))
          'progress': state.metadata['progress'],
        if (state.metadata.containsKey('issues'))
          'issues': state.metadata['issues'],
        if (state.editablePatterns.isNotEmpty ||
            state.readOnlyPatterns.isNotEmpty ||
            state.nextCommand != null ||
            state.allowedCommands.isNotEmpty)
          'allowed_actions': {
            'editable_files': state.editablePatterns,
            'read_only_files': state.readOnlyPatterns,
            if (state.nextCommand != null) 'next_command': state.nextCommand,
            if (state.allowedCommands.isNotEmpty)
              'allowed_commands': state.allowedCommands,
          },
        'instructions_for_agent': error,
      };
      _print(jsonEncode(jsonOutput));
    } else {
      this.error('[${state.phase}] $error');
    }
  }
}
