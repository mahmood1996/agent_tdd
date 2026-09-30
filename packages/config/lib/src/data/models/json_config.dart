import 'dart:convert';
import 'package:cactoos_dart/cactoos_dart.dart';
import '../../domain/models/config.dart';

/// A default [Config] implementation using [LazyMap] to lazily parse or evaluate configuration maps.
final class JsonConfig implements Config {
  late final LazyMap<String, dynamic, dynamic> _map;

  /// Creates a [JsonConfig] by wrapping a raw JSON string into a [LazyMap].
  JsonConfig(String jsonString) {
    _map = LazyMap<String, dynamic, dynamic>(
      src: () => jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Creates a [JsonConfig] from a custom map supplier.
  JsonConfig.fromSupplier(Map<String, dynamic> Function() supplier) {
    _map = LazyMap<String, dynamic, dynamic>(src: supplier);
  }

  /// Creates a [JsonConfig] from an existing Map.
  JsonConfig.fromMap(Map<String, dynamic> map) {
    _map = LazyMap<String, dynamic, dynamic>(src: () => map);
  }

  @override
  V valueBy<V>(String key, V fallback) {
    final val = _map[key];
    if (val is V) {
      return val;
    }
    return fallback;
  }

  @override
  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.unmodifiable(_map);
  }
}
