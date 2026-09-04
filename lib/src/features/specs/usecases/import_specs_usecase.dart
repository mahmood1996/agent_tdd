import '../../../core/data/spec_store.dart';

final class ImportSpecsResult {
  final String filePath;

  const ImportSpecsResult({required this.filePath});
}

final class ImportSpecsUseCase {
  final String projectDir;
  final SpecStore specStore;

  ImportSpecsUseCase({
    required this.projectDir,
    SpecStore? specStore,
  }) : specStore = specStore ?? SpecStore(projectDir: projectDir);

  Future<ImportSpecsResult> execute(String filePath) async {
    await specStore.importSpecsFrom(filePath);
    return ImportSpecsResult(filePath: filePath);
  }
}


