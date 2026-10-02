/// Abstract interface for reading configuration values by key with a fallback.
abstract interface class ReadableConfig {
  /// A config with no entries — every key lookup returns its [fallback].
  static const ReadableConfig empty = _EmptyConfig();

  /// Retrieves a value by [key], returning [fallback] if not found or null.
  V valueBy<V>(String key, V fallback);
}

/// Null-object implementation of [ReadableConfig].
/// Always returns the caller's [fallback], making absent-config handling
/// the responsibility of this single class rather than every implementor.
final class _EmptyConfig implements ReadableConfig {
  const _EmptyConfig();

  @override
  V valueBy<V>(String key, V fallback) => fallback;
}
