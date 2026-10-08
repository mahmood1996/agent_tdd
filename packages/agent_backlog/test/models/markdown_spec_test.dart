import 'package:agent_backlog/agent_backlog.dart';
import 'package:test/test.dart';

void main() {
  group('MarkdownSpec Tests', () {
    test('parses minimal completed spec string', () {
      final spec = MarkdownSpec("- [X] fizzBuzz(5) returns 'Buzz'");

      expect(spec.status, equals('done'));
      expect(spec.isDone, isTrue);
      expect(spec.isPending, isFalse);
      expect(spec.isInProgress, isFalse);
      expect(spec.id, equals(0));
      expect(spec.title, equals("fizzBuzz(5) returns 'Buzz'"));
      expect(spec.description, isEmpty);
      expect(spec.metadata, isEmpty);
    });

    test('parses lowercase completed marker [x]', () {
      final spec = MarkdownSpec("- [x] fizzBuzz(5) returns 'Buzz'");

      expect(spec.status, equals('done'));
      expect(spec.isDone, isTrue);
    });

    test('parses pending spec string with [ ] and []', () {
      final pendingWithSpace = MarkdownSpec("- [ ] fizzBuzz(3) returns 'Fizz'");
      expect(pendingWithSpace.status, equals('pending'));
      expect(pendingWithSpace.isPending, isTrue);
      expect(pendingWithSpace.isDone, isFalse);
      expect(pendingWithSpace.title, equals("fizzBuzz(3) returns 'Fizz'"));

      final pendingEmpty = MarkdownSpec("- [] fizzBuzz(3) returns 'Fizz'");
      expect(pendingEmpty.status, equals('pending'));
      expect(pendingEmpty.isPending, isTrue);
      expect(pendingEmpty.title, equals("fizzBuzz(3) returns 'Fizz'"));
    });

    test('parses in_progress spec string with [/] and [-]', () {
      final inProgressSlash = MarkdownSpec("- [/] in progress task");
      expect(inProgressSlash.status, equals('in_progress'));
      expect(inProgressSlash.isInProgress, isTrue);
      expect(inProgressSlash.title, equals('in progress task'));

      final inProgressDash = MarkdownSpec("- [-] another in progress task");
      expect(inProgressDash.status, equals('in_progress'));
      expect(inProgressDash.isInProgress, isTrue);
      expect(inProgressDash.title, equals('another in progress task'));
    });

    test('parses full unified string with id, description, and metadata', () {
      final spec = MarkdownSpec(
        "- [X] #1 fizzBuzz(5) returns 'Buzz' :: Must handle 5, 10, 20 <!-- {\"priority\": \"high\", \"points\": 3} -->",
      );

      expect(spec.id, equals(1));
      expect(spec.status, equals('done'));
      expect(spec.title, equals("fizzBuzz(5) returns 'Buzz'"));
      expect(spec.description, equals('Must handle 5, 10, 20'));
      expect(spec.metadata, equals({'priority': 'high', 'points': 3}));
    });

    test('parses metadata from trailing JSON without html comments', () {
      final spec = MarkdownSpec(
        "- [ ] #42 calculateTotal() :: Computes order total {\"tags\": [\"billing\"]}",
      );

      expect(spec.id, equals(42));
      expect(spec.status, equals('pending'));
      expect(spec.title, equals('calculateTotal()'));
      expect(spec.description, equals('Computes order total'));
      expect(spec.metadata, equals({'tags': ['billing']}));
    });

    test('supports alternative bullet markers * and +', () {
      final star = MarkdownSpec("* [X] star bullet");
      expect(star.status, equals('done'));
      expect(star.title, equals('star bullet'));

      final plus = MarkdownSpec("+ [ ] plus bullet");
      expect(plus.status, equals('pending'));
      expect(plus.title, equals('plus bullet'));
    });

    test('gracefully falls back on plain or malformed strings without throwing', () {
      final plain = MarkdownSpec('just a plain note');
      expect(plain.status, equals('pending'));
      expect(plain.title, equals('just a plain note'));
      expect(plain.id, equals(0));
      expect(plain.description, isEmpty);
      expect(plain.metadata, isEmpty);

      final brokenJson = MarkdownSpec('- [ ] broken json <!-- {not:json} -->');
      expect(brokenJson.status, equals('pending'));
      expect(brokenJson.title, equals('broken json'));
      expect(brokenJson.metadata, isEmpty);

      final empty = MarkdownSpec('');
      expect(empty.title, isEmpty);
      expect(empty.status, equals('pending'));
    });

    test('works with Spec.fromMarkdown factory constructor', () {
      final Spec spec = Spec.fromMarkdown("- [X] #7 factory spec");

      expect(spec.id, equals(7));
      expect(spec.status, equals('done'));
      expect(spec.title, equals('factory spec'));
    });

    test('interoperates seamlessly with SmartSpec extension', () {
      final spec = MarkdownSpec("- [ ] #1 original task");
      expect(spec.isPending, isTrue);

      final done = spec.markedAsDone();
      expect(done.isDone, isTrue);
      expect(done.status, equals('done'));
      expect(done.id, equals(1));
      expect(done.title, equals('original task'));

      final json = spec.toJson();
      expect(json['id'], equals(1));
      expect(json['title'], equals('original task'));
      expect(json['status'], equals('pending'));
    });
  });
}
