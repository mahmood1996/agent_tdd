import 'dart:io';

import 'package:agent_backlog/agent_backlog.dart';

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
  }) : specStore = specStore ?? FileSpecStore(projectDir, 'specs.yaml');

  Future<ImportSpecsResult> execute(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Markdown file not found: $filePath');
    }

    final content = await file.readAsString();
    await specStore.addSpecs(NewSpecs.fromMarkdown(content));
    return ImportSpecsResult(filePath: filePath);
  }
}
