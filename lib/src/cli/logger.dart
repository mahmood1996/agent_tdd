import 'dart:convert';
import 'dart:io';

final class Logger {
  static bool jsonOutput = true;

  static void info(String msg) {
    if (jsonOutput) return;
    print(msg);
  }

  static void error(String msg) {
    if (jsonOutput) return;
    stderr.writeln('\x1B[31m❌ $msg\x1B[0m');
  }

  static void success(String msg) {
    if (jsonOutput) return;
    print('\x1B[32m✅ $msg\x1B[0m');
  }

  static void warning(String msg) {
    if (jsonOutput) return;
    print('\x1B[33m⚠️  $msg\x1B[0m');
  }

  static void agentJson({
    required bool success,
    required String phase,
    Map<String, dynamic>? activeSpec,
    Map<String, dynamic>? allowedActions,
    Map<String, dynamic>? progress,
    List<dynamic>? issues,
    required String instructionsForAgent,
  }) {
    final payload = {
      'success': success,
      'phase': phase,
      if (activeSpec != null) 'active_spec': activeSpec,
      if (allowedActions != null) 'allowed_actions': allowedActions,
      if (progress != null) 'progress': progress,
      if (issues != null) 'issues': issues,
      'instructions_for_agent': instructionsForAgent,
    };
    print(jsonEncode(payload));
  }
}
