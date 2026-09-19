import 'dart:convert';
import '../models/harness_state.dart';

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

  ConsoleOutput({
    this.isJsonMode = false,
    this.printHandler,
  });

  void _print(String text) => (printHandler ?? print).call(text);

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
    isJsonMode
        ? _print(jsonEncode(state.toSuccessJson(message)))
        : info('[${state.phase}] $message');
  }

  @override
  void reportFailure({required String error, required HarnessState state}) {
    isJsonMode
        ? _print(jsonEncode(state.toFailureJson(error)))
        : this.error('[${state.phase}] $error');
  }
}
