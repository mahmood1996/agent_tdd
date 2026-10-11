import 'package:agent_backlog/agent_backlog.dart';

/// Extension type wrapping [SpecStore] with TDD harness domain-specific methods.
extension type TddSpecStore(SpecStore _store) implements SpecStore {
  /// Convenience constructor creating a [FileSpecStore] wrapped in [TddSpecStore].
  TddSpecStore.file(String projectDir, [String fileName = 'specs.yaml'])
      : this(FileSpecStore(projectDir, fileName));

  static const _activeStatuses = {'red', 'green', 'refactor', 'already_passed'};

  /// Gets the currently active spec undergoing TDD lifecycle phases, or null if none.
  Future<Spec?> activeSpec() async =>
      (await specs()).where((s) => _activeStatuses.contains(s.status)).firstOrNull;

  /// Returns a summary map of the current backlog state for CLI presentation.
  Future<Map<String, dynamic>> summary() async {
    final list = await specs();
    final total = list.length;
    final completed = list.where((s) => s.isDone).length;
    final percentage = total == 0 ? 0 : ((completed / total) * 100).round();

    return {
      'total': total,
      'completed': completed,
      'percentage': percentage,
      'active_spec': (await activeSpec())?.toJson(),
      'specs': list.map((s) => s.toJson()).toList(),
    };
  }
}
