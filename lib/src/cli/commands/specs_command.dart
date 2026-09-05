import 'package:agent_harness/agent_harness.dart';
import '../../core/data/spec_store.dart';
import '../../features/specs/usecases/add_spec_usecase.dart';
import '../../features/specs/usecases/import_specs_usecase.dart';
import '../../features/specs/usecases/list_specs_usecase.dart';

final class SpecsCommand implements HarnessCommand {
  final String projectDir;
  final SpecStore specStore;
  final StateStore stateStore;
  final HarnessOutput output;

  const SpecsCommand({
    required this.projectDir,
    required this.specStore,
    required this.stateStore,
    this.output = const ConsoleOutput(isJsonMode: true),
  });

  @override
  String get name => 'specs';

  @override
  String get description => 'Manages feature specs backlog (list, add, import).';

  @override
  Future<void> execute([List<String> args = const []]) async {
    if (args.isEmpty || args.first == 'list') {
      final useCase = ListSpecsUseCase(
        projectDir: projectDir,
        specStore: specStore,
        stateStore: stateStore,
      );
      final res = await useCase.execute();
      final state = await stateStore.harnessState();

      output.reportSuccess(
        message: 'Specs backlog listed.',
        state: state.copyWith(
          metadata: {
            ...state.metadata,
            'progress': res.summary,
          },
        ),
      );
      return;
    }

    final subCmd = args.first;
    if (subCmd == 'add') {
      final state = await stateStore.harnessState();
      if (args.length <= 1) {
        output.reportFailure(
          error: 'Missing spec title. Usage: agent-tdd specs add "<title>"',
          state: state,
        );
        return;
      }

      final title = args.sublist(1).join(' ');
      final useCase = AddSpecUseCase(
        projectDir: projectDir,
        specStore: specStore,
        stateStore: stateStore,
      );
      final res = await useCase.execute(title);
      final updatedState = await stateStore.harnessState();

      output.reportSuccess(
        message: 'Added spec #${res.newSpec.id}: "$title".',
        state: updatedState.copyWith(
          metadata: {
            ...updatedState.metadata,
            'active_spec': res.newSpec.toJson(),
          },
        ),
      );
      return;
    }

    if (subCmd == 'import') {
      final state = await stateStore.harnessState();
      if (args.length <= 1) {
        output.reportFailure(
          error: 'Missing file path. Usage: agent-tdd specs import <file.md|file.yaml>',
          state: state,
        );
        return;
      }

      final useCase = ImportSpecsUseCase(
        projectDir: projectDir,
        specStore: specStore,
      );
      final res = await useCase.execute(args[1]);

      output.reportSuccess(
        message: 'Imported specs from ${res.filePath}!',
        state: state,
      );
      return;
    }

    final state = await stateStore.harnessState();
    output.reportFailure(
      error: 'Unknown specs subcommand "$subCmd". Usage: agent-tdd specs [list|add|import]',
      state: state,
    );
  }
}
