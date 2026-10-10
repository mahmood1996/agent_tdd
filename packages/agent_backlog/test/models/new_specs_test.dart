import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

void main() {
  group('NewSpecs.fromMarkdown', () {
    test('extracts checklist items and ignores non-checklist lines', () {
      final markdown = '''
# Feature Backlog
Introductory text here.

- [ ] fizzBuzzFor(5) returns 'Buzz'
- Non-checklist item
* [ ] fizzBuzzFor(3) returns 'Fizz'
Some trailing remarks.
- [x] add(1, 2) returns 3
* [X] subtract(2, 1) returns 1
''';

      final specs = NewSpecs.fromMarkdown(markdown).toList();

      expect(specs.length, equals(4));
      expect(specs[0].title, equals("fizzBuzzFor(5) returns 'Buzz'"));
      expect(specs[0].status, equals('pending'));
      expect(specs[1].title, equals("fizzBuzzFor(3) returns 'Fizz'"));
      expect(specs[1].status, equals('pending'));
      expect(specs[2].title, equals('add(1, 2) returns 3'));
      expect(specs[2].status, equals('done'));
      expect(specs[3].title, equals('subtract(2, 1) returns 1'));
      expect(specs[3].status, equals('done'));
    });

    test('parses title, description, and metadata with pipe delimiters', () {
      final markdown = '''
- [ ] Task with all fields | Detailed description of the task | priority:high tags:core estimate:2h
- [ ] Task with title and desc | Just description
- [ ] Task with title only
''';

      final specs = NewSpecs.fromMarkdown(markdown).toList();

      expect(specs.length, equals(3));

      // Task 1
      expect(specs[0].title, equals('Task with all fields'));
      expect(specs[0].description, equals('Detailed description of the task'));
      expect(specs[0].status, equals('pending'));
      expect(specs[0].metadata, equals({
        'priority': 'high',
        'tags': 'core',
        'estimate': '2h',
      }));

      // Task 2
      expect(specs[1].title, equals('Task with title and desc'));
      expect(specs[1].description, equals('Just description'));
      expect(specs[1].status, equals('pending'));
      expect(specs[1].metadata, isEmpty);

      // Task 3
      expect(specs[2].title, equals('Task with title only'));
      expect(specs[2].description, equals(''));
      expect(specs[2].status, equals('pending'));
      expect(specs[2].metadata, isEmpty);
    });

    test('handles empty markdown or markdown without checklist items', () {
      final empty = NewSpecs.fromMarkdown('');
      expect(empty.isEmpty, isTrue);
      expect(empty.length, equals(0));

      final noChecklist = NewSpecs.fromMarkdown('# Header\nJust text\n- list item');
      expect(noChecklist.isEmpty, isTrue);
      expect(noChecklist.length, equals(0));
    });

    test('supports full Iterable operations', () {
      final specs = NewSpecs.fromMarkdown('''
- [ ] First
- [ ] Second
- [x] Third
''');

      expect(specs.isNotEmpty, isTrue);
      expect(specs.length, equals(3));
      expect(specs.first.title, equals('First'));
      expect(specs.last.title, equals('Third'));
      expect(specs.where((s) => s.status == 'pending').length, equals(2));
      expect(specs.map((s) => s.title).toList(), equals(['First', 'Second', 'Third']));
    });

    test('lazily parses spec fields only when accessed', () {
      final specs = NewSpecs.fromMarkdown('- [ ] Lazy task | Some details | key:value');
      final firstSpec = specs.first;

      // Accessing status first works without error
      expect(firstSpec.status, equals('pending'));
      // Then other fields
      expect(firstSpec.title, equals('Lazy task'));
      expect(firstSpec.description, equals('Some details'));
      expect(firstSpec.metadata, equals({'key': 'value'}));
    });
  });
}
