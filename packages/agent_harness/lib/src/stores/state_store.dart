import '../models/harness_state.dart';

/// Abstract interface for persistent state storage
abstract interface class StateStore {
  /// Retrieves persistent harness state
  Future<HarnessState> savedState();

  /// Saves persistent harness state
  Future<void> saveState(HarnessState state);
}
