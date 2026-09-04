import 'package:agent_harness/agent_harness.dart';
import 'package:test/test.dart';

class MemoryStateStore implements StateStore {
  HarnessState _state;

  MemoryStateStore(this._state);

  @override
  Future<HarnessState> loadState() async => _state;

  @override
  Future<void> saveState(HarnessState state) async {
    _state = state;
  }

  @override
  Future<void> resetState() async {
    _state = const HarnessState(
      phase: 'IDLE',
      editablePatterns: [],
      readOnlyPatterns: [],
    );
  }
}

class SampleCommand implements HarnessCommand {
  final StateStore stateStore;
  final HarnessOutput output;

  SampleCommand(this.stateStore, this.output);

  @override
  String get name => 'sample';

  @override
  String get description => 'Sample test command';

  @override
  Future<void> execute() async {
    final state = await stateStore.loadState();
    final newState = state.copyWith(
      phase: 'GREEN',
      editablePatterns: ['lib/**/*.dart'],
    );
    await stateStore.saveState(newState);
    output.reportSuccess(message: 'Sample executed successfully', state: newState);
  }
}

void main() {
  group('agent_harness Core Tests', () {
    test('HarnessState serialization', () {
      final state = HarnessState(
        phase: 'RED',
        editablePatterns: ['test/**/*.dart'],
        readOnlyPatterns: ['lib/**/*.dart'],
        nextCommand: 'verify-red',
      );

      final json = state.toJson();
      expect(json['phase'], equals('RED'));
      expect(json['next_command'], equals('verify-red'));

      final parsed = HarnessState.fromJson(json);
      expect(parsed.phase, equals('RED'));
      expect(parsed.editablePatterns, contains('test/**/*.dart'));
    });

    test('ConsoleOutput json reporting', () {
      final outputs = <String>[];
      final output = ConsoleOutput(
        isJsonMode: true,
        printHandler: outputs.add,
      );

      final state = const HarnessState(
        phase: 'GREEN',
        editablePatterns: ['lib/**/*.dart'],
        readOnlyPatterns: ['test/**/*.dart'],
      );

      output.reportSuccess(message: 'Tests passed', state: state);

      expect(outputs.length, equals(1));
      expect(outputs.first, contains('"success":true'));
      expect(outputs.first, contains('"phase":"GREEN"'));
    });

    test('SampleCommand executes and updates StateStore', () async {
      final outputs = <String>[];
      final store = MemoryStateStore(const HarnessState(
        phase: 'RED',
        editablePatterns: [],
        readOnlyPatterns: [],
      ));

      final output = ConsoleOutput(
        isJsonMode: true,
        printHandler: outputs.add,
      );

      final command = SampleCommand(store, output);
      await command.execute();

      final updatedState = await store.loadState();
      expect(updatedState.phase, equals('GREEN'));
      expect(outputs.first, contains('"phase":"GREEN"'));
    });
  });
}
