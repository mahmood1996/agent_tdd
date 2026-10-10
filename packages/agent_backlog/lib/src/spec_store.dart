import 'models/new_spec.dart';
import 'models/new_specs.dart';
import 'models/spec.dart';

/// Abstract interface for spec backlog storage and retrieval
abstract interface class SpecStore {
  /// Loads all specs from persistent storage
  Future<List<Spec>> specs();

  /// Adds one or more new specs to persistent storage in a single write
  Future<void> addSpecs(Iterable<NewSpec> specs);

  /// Updates the status of a specific spec by ID and persists the change
  Future<void> updateSpecStatus(int specId, String newStatus);
}

/// Extension providing high-level helper methods on top of [SpecStore]
extension SmartSpecStore on SpecStore {
  /// Adds a single new spec to persistent storage
  Future<void> addSpec(String title, [String description = '']) async {
    await addSpecs(NewSpecs.fromMarkdown('- [ ] $title | $description'));
  }

  /// Gets the next pending spec, or null if all specs are complete
  Future<Spec?> nextPendingSpec() async =>
      (await specs()).where((t) => t.isPending).firstOrNull;

  /// Marks a specific spec as done by ID and persists the change
  Future<void> markSpecDone(
    int specId,
  ) async =>
      await updateSpecStatus(specId, 'done');

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

  Future<Spec?> activeSpec() async =>
      (await specs()).where((t) => !t.isDone).firstOrNull;
}
