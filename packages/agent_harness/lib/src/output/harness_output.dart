import 'dart:convert';

/// Abstract interface for terminal and machine-readable JSON stdout/stderr reporting
abstract interface class HarnessOutput {
  void display(String message);
}

final class Message {
  factory Message.info(String txt) => Message._(() => 'ℹ️ $txt');

  factory Message.error(String txt) => Message._(() => '\x1B[31m❌ $txt\x1B[0m');

  factory Message.success(String txt) =>
      Message._(() => '\x1B[32m✅ $txt\x1B[0m');

  factory Message.warning(String txt) =>
      Message._(() => '\x1B[33m⚠️  $txt\x1B[0m');

  factory Message.json(Map<String, dynamic> json) =>
      Message._(() => jsonEncode(json));

  const Message._(this._message);

  final String Function() _message;

  @override
  String toString() => _message();
}

final class ConsoleOutput implements HarnessOutput {
  ConsoleOutput({
    required void Function(String) printHandler,
  }) : _printHandler = printHandler;

  final void Function(String text) _printHandler;

  @override
  void display(String message) => _printHandler(message);
}
