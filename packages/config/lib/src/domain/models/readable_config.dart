/// Abstract interface for reading configuration values by key with a fallback.
abstract interface class ReadableConfig {
  /// Retrieves a value by [key], returning [fallback] if not found or null.
  V valueBy<V>(String key, V fallback);
}
