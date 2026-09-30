/// Abstract interface for serializing configuration data to a Map.
abstract interface class SerializableConfig {
  /// Converts configuration entries into a [Map].
  Map<String, dynamic> toMap();
}
