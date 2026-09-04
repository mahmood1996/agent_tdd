import '../logger.dart';

abstract class BasePresenter {
  const BasePresenter();

  Map<String, dynamic>? activeSpecMap(int? id, String? title) {
    if (id == null) return null;
    return {'id': id, 'title': title};
  }

  Map<String, dynamic> allowedActionsMap({
    required List<String> editableFiles,
    required List<String> readOnlyFiles,
    required String nextCommand,
  }) {
    return {
      'editable_files': editableFiles,
      'read_only_files': readOnlyFiles,
      'next_command': nextCommand,
    };
  }

  void renderError({
    required String message,
    required String phase,
    Map<String, dynamic>? activeSpec,
    Map<String, dynamic>? allowedActions,
    List<dynamic>? issues,
  }) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: false,
        phase: phase,
        activeSpec: activeSpec,
        allowedActions: allowedActions,
        issues: issues,
        instructionsForAgent: message,
      );
    } else {
      Logger.error(message);
    }
  }

  void renderUnknownCommand(String command, String phase) {
    final msg =
        'Unknown command: "$command". Available commands: init, specs, next, verify-red, verify-green, verify-refactor, complete, status, reset.';
    renderError(message: msg, phase: phase);
  }
}
