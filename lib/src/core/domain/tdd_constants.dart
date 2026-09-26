/// Shared constants for the agent_tdd harness.
abstract final class TddConstants {
  /// Name of the JSON file used to persist the test-file snapshot.
  ///
  /// Written to the root of the project directory, e.g.:
  /// `<projectDir>/.agent_tdd_snapshot.json`.
  static const String snapshotFileName = '.agent_tdd_snapshot.json';
}
