import '../../core/data/spec_store.dart';
import '../../core/data/tdd_cycle.dart';
import '../../features/specs/usecases/add_spec_usecase.dart';
import '../../features/specs/usecases/import_specs_usecase.dart';
import '../../features/specs/usecases/list_specs_usecase.dart';
import '../presenter/specs_presenter.dart';

final class SpecsCommand {
  final String projectDir;
  final SpecStore specStore;
  final TddCycle tddCycle;
  final SpecsPresenter presenter;

  const SpecsCommand({
    required this.projectDir,
    required this.specStore,
    required this.tddCycle,
    this.presenter = const SpecsPresenter(),
  });

  Future<void> execute(List<String> args) async {
    if (args.isEmpty || args.first == 'list') {
      final useCase = ListSpecsUseCase(
        projectDir: projectDir,
        specStore: specStore,
        tddCycle: tddCycle,
      );
      final res = await useCase.execute();
      presenter.renderSpecsList(res);
      return;
    }

    final subCmd = args.first;
    if (subCmd == 'add') {
      if (args.length <= 1) {
        final state = await tddCycle.savedTddState();
        presenter.renderSpecsAddError(
          'Missing spec title. Usage: agent-tdd specs add "<title>"',
          state.phase.name.toUpperCase(),
        );
        return;
      }

      final title = args.sublist(1).join(' ');
      final useCase = AddSpecUseCase(
        projectDir: projectDir,
        specStore: specStore,
        tddCycle: tddCycle,
      );
      final res = await useCase.execute(title);
      presenter.renderSpecsAddSuccess(res, title);
      return;
    }

    if (subCmd == 'import') {
      if (args.length <= 1) {
        final state = await tddCycle.savedTddState();
        presenter.renderSpecsImportError(
          'Missing file path. Usage: agent-tdd specs import <file.md|file.yaml>',
          state.phase.name.toUpperCase(),
        );
        return;
      }

      final useCase = ImportSpecsUseCase(
        projectDir: projectDir,
        specStore: specStore,
      );
      final res = await useCase.execute(args[1]);
      final state = await tddCycle.savedTddState();
      presenter.renderSpecsImportSuccess(res, state);
      return;
    }

    final state = await tddCycle.savedTddState();
    presenter.renderSpecsUnknownSubcommand(subCmd, state.phase.name.toUpperCase());
  }
}
