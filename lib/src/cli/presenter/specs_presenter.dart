import '../../core/domain/tdd_state.dart';
import '../../features/specs/usecases/add_spec_usecase.dart';
import '../../features/specs/usecases/import_specs_usecase.dart';
import '../../features/specs/usecases/list_specs_usecase.dart';
import '../logger.dart';
import 'base_presenter.dart';

final class SpecsPresenter extends BasePresenter {
  const SpecsPresenter();

  void renderSpecsList(ListSpecsResult res) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: res.currentState.phase.name.toUpperCase(),
        progress: res.summary,
        instructionsForAgent: 'Specs backlog listed.',
      );
      return;
    }

    Logger.info(
        '📋 Feature Specs Backlog (${res.summary['completed']}/${res.summary['total']} completed):');
    for (final spec in res.specs) {
      final mark =
          spec.status == 'done' ? '✅' : (spec.status == 'pending' ? '⏳' : '🔄');
      Logger.info(
          '  $mark #${spec.id}: ${spec.title} [Status: ${spec.status}]');
    }
  }

  void renderSpecsAddError(String message, String phase) {
    renderError(message: message, phase: phase);
  }

  void renderSpecsAddSuccess(AddSpecResult res, String title) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: res.currentState.phase.name.toUpperCase(),
        activeSpec: res.newSpec.toJson(),
        instructionsForAgent: 'Added spec #${res.newSpec.id}: "$title".',
      );
    } else {
      Logger.success('Added Spec #${res.newSpec.id}: "$title"');
    }
  }

  void renderSpecsImportError(String message, String phase) {
    renderError(message: message, phase: phase);
  }

  void renderSpecsImportSuccess(ImportSpecsResult res, TddState state) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: state.phase.name.toUpperCase(),
        instructionsForAgent: 'Imported specs from ${res.filePath}!',
      );
    } else {
      Logger.success('Imported specs from ${res.filePath}!');
    }
  }

  void renderSpecsUnknownSubcommand(String subCmd, String phase) {
    final msg =
        'Unknown specs subcommand "$subCmd". Usage: agent-tdd specs [list|add|import]';
    renderError(message: msg, phase: phase);
  }
}
