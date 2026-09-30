import 'readable_config.dart';
import 'serializable_config.dart';

/// Unifies reading and serialization capabilities for application configuration.
abstract interface class Config implements SerializableConfig, ReadableConfig {}
