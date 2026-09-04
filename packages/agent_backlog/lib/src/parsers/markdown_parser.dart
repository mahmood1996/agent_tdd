import '../harness_task.dart';

/// Helper for parsing markdown checklists into HarnessTask objects
final class MarkdownTaskParser {
  static List<HarnessTask> parse(String markdownContent) {
    final lines = markdownContent.split('\n');
    final tasks = <HarnessTask>[];
    int nextId = 1;

    final checkboxPattern = RegExp(r'^\s*-\s*\[([ xX])\]\s*(.+)');

    for (final line in lines) {
      final match = checkboxPattern.firstMatch(line);
      if (match != null) {
        final isChecked = match.group(1)!.trim().toLowerCase() == 'x';
        final title = match.group(2)!.trim();

        tasks.add(HarnessTask(
          id: nextId++,
          title: title,
          status: isChecked ? 'done' : 'pending',
        ));
      }
    }

    return tasks;
  }
}
