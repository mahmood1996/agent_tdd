import '../models/config.dart';
import '../models/serializable_config.dart';

/// Abstract storage boundary for loading and persisting configuration instances.
abstract interface class ConfigStore {
  /// Loads the stored configuration, or returns `null` if none exists.
  Future<Config?> config();

  /// Persists a [SerializableConfig] instance.
  Future<void> save(SerializableConfig conf);
}
