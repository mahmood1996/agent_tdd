import 'dart:convert';
import 'package:cactoos_dart/cactoos_dart.dart';
import '../../domain/models/config.dart';

/// A default [Config] implementation using [LazyMap] to lazily parse or evaluate configuration maps.
final class JsonConfig implements Config {
  /// Creates a [JsonConfig] by wrapping a raw JSON string into a [LazyMap].
  JsonConfig(String jsonString)
    : _map = LazyMap<String, dynamic, dynamic>(
        src: () => jsonDecode(jsonString) as Map<String, dynamic>,
      );

  final Map<String, dynamic> _map;

  @override
  V valueBy<V>(String key, V fallback) => switch (_map[key]) {
    final value when value is V => value,
    _ => fallback,
  };

  @override
  Map<String, dynamic> toMap() => Map<String, dynamic>.unmodifiable(_map);
}
