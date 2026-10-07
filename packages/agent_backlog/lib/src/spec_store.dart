import 'dart:collection';

import 'models/spec.dart';

/// Abstract interface for spec backlog storage and retrieval
abstract interface class SpecStore {
  /// Loads all specs from persistent storage
  Future<List<Spec>> specs();

  /// Saves all specs to persistent storage
  Future<void> saveSpecs(List<Spec> specs);
}

/// Extension providing high-level helper methods on top of [SpecStore]
extension SmartSpecStore on SpecStore {
  /// Gets the next pending spec, or null if all specs are complete
  Future<Spec?> nextPendingSpec() async =>
      (await specs()).where((t) => t.isPending).firstOrNull;

  /// Marks a specific spec as done by ID and persists the change
  Future<void> markSpecDone(
    int specId,
  ) async =>
      await saveSpecs(
        (await specs())
            .map((t) => t.id == specId ? t.markedAsDone() : t)
            .toList(),
      );

  /// Updates the status of a specific spec by ID and persists the change
  Future<void> updateSpecStatus(int specId, String status) async =>
      await saveSpecs(
        (await specs())
            .map((t) => t.id == specId ? t.copyWith(status: status) : t)
            .toList(),
      );

  Future<Map<String, dynamic>> summary() async {
    final list = await specs();
    final total = list.length;
    final completed = list.where((s) => s.isDone).length;
    final percentage = total == 0 ? 0 : ((completed / total) * 100).round();

    return {
      'total': total,
      'completed': completed,
      'percentage': percentage,
      'active_spec': (await _activeSpec())?.toJson(),
      'specs': list.map((s) => s.toJson()).toList(),
    };
  }

  Future<Spec?> _activeSpec() async =>
      (await specs()).where((t) => !t.isDone).firstOrNull;
}
