import 'harness_state.dart';

/// Abstract interface for persistent state storage
abstract interface class StateStore {
  /// Loads persistent harness state
  Future<HarnessState> loadState();

  /// Saves persistent harness state
  Future<void> saveState(HarnessState state);

  /// Resets persistent harness state to default/idle
  Future<void> resetState();
}
