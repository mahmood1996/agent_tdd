import 'dart:async';

/// Abstract interface for a self-contained harness command.
abstract interface class HarnessCommand {
  /// Unique name of the command (e.g. 'verify-red', 'next')
  String get name;

  /// Description of what the command performs
  String get description;

  /// Executes internal evaluation, updates persistent state, and outputs to HarnessOutput/stdout.
  Future<void> execute();
}
